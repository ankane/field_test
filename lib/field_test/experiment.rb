module FieldTest
  class Experiment
    attr_reader :id, :name, :description, :variants, :weights, :winner, :started_at, :ended_at, :goals

    def initialize(attributes)
      attributes = attributes.symbolize_keys
      @id = attributes[:id]
      @name = attributes[:name] || @id.to_s.titleize
      @description = attributes[:description]
      @variants = attributes[:variants]
      @weights = @variants.size.times.map { |i| attributes[:weights].to_a[i] || 1 }
      @winner = attributes[:winner]
      @closed = attributes[:closed]
      @keep_variant = attributes[:keep_variant]
      @started_at = Time.zone.parse(attributes[:started_at].to_s) if attributes[:started_at]
      @ended_at = Time.zone.parse(attributes[:ended_at].to_s) if attributes[:ended_at]
      @goals = attributes[:goals] || ["conversion"]
      @goals_defined = !attributes[:goals].nil?
      @use_events = attributes[:use_events]
    end

    def variant(participants, options = {})
      return winner if winner && !keep_variant?
      return control if options[:exclude]

      participants = FieldTest::Participant.standardize(participants)
      check_participants(participants)
      membership = membership_for(participants) || FieldTest::Membership.new(experiment: id)

      if winner # and keep_variant?
        return membership.variant || winner
      end

      if options[:variant] && variants.include?(options[:variant])
        membership.variant = options[:variant]
      else
        membership.variant ||= closed? ? control : weighted_variant
      end

      participant = participants.first

      # upgrade to preferred participant
      membership.participant = participant.participant if membership.respond_to?(:participant=)
      membership.participant_type = participant.type if membership.respond_to?(:participant_type=)
      membership.participant_id = participant.id if membership.respond_to?(:participant_id=)

      if membership.changed? && (!closed? || membership.persisted?)
        begin
          membership.save!
        rescue ActiveRecord::RecordNotUnique
          membership = memberships.find_by(participant.where_values)
        end
      end

      membership.try(:variant) || control
    end

    def convert(participants, goal: nil)
      return false if winner

      goal ||= goals.first

      participants = FieldTest::Participant.standardize(participants)
      check_participants(participants)
      membership = membership_for(participants)

      if membership
        if membership.respond_to?(:converted)
          membership.converted = true
          membership.save! if membership.changed?
        end

        if use_events?
          FieldTest::Event.create!(
            name: goal,
            field_test_membership_id: membership.id
          )
        end

        true
      else
        false
      end
    end

    def memberships
      FieldTest::Membership.where(experiment: id)
    end

    def events
      FieldTest::Event.joins(:field_test_membership).where(field_test_memberships: {experiment: id})
    end

    def multiple_goals?
      goals.size > 1
    end

    def results(goal: nil)
      goal ||= goals.first

      relation = memberships.group(:variant)
      relation = relation.where("field_test_memberships.created_at >= ?", started_at) if started_at
      relation = relation.where("field_test_memberships.created_at <= ?", ended_at) if ended_at

      if use_events? && @goals_defined
        data = {}

        participated = relation.count

        adapter_name = relation.connection.adapter_name
        column =
          if FieldTest.legacy_participants
            :participant
          elsif adapter_name =~ /postg/i # postgres
            "(participant_type, participant_id)"
          elsif adapter_name =~ /mysql/i
            "participant_type, participant_id"
          else
            # not perfect, but it'll do
            "COALESCE(participant_type, '') || ':' || participant_id"
          end

        converted = events.merge(relation).where(field_test_events: {name: goal}).distinct.count(column)

        (participated.keys + converted.keys).uniq.each do |variant|
          data[[variant, true]] = converted[variant].to_i
          data[[variant, false]] = participated[variant].to_i - converted[variant].to_i
        end
      else
        data = relation.group(:converted).count
      end

      results = {}
      variants.each do |variant|
        converted = data[[variant, true]].to_i
        participated = converted + data[[variant, false]].to_i
        results[variant] = {
          participated: participated,
          converted: converted,
          conversion_rate: participated > 0 ? converted.to_f / participated : nil
        }
      end

      case variants.size
      when 1, 2, 3
        total = 0.0

        (variants.size - 1).times do |i|
          c = results.values[i]
          b = results.values[(i + 1) % variants.size]
          a = results.values[(i + 2) % variants.size]

          alpha_a = 1 + a[:converted]
          beta_a = 1 + a[:participated] - a[:converted]
          alpha_b = 1 + b[:converted]
          beta_b = 1 + b[:participated] - b[:converted]
          alpha_c = 1 + c[:converted]
          beta_c = 1 + c[:participated] - c[:converted]

          # TODO calculate this incrementally by caching intermediate results
          prob_winning =
            if variants.size == 2
              cache_fetch ["field_test", "prob_b_beats_a", alpha_b, beta_b, alpha_c, beta_c] do
                Calculations.prob_b_beats_a(alpha_b, beta_b, alpha_c, beta_c)
              end
            else
              cache_fetch ["field_test", "prob_c_beats_a_and_b", alpha_a, beta_a, alpha_b, beta_b, alpha_c, beta_c] do
                Calculations.prob_c_beats_a_and_b(alpha_a, beta_a, alpha_b, beta_b, alpha_c, beta_c)
              end
            end

          results[variants[i]][:prob_winning] = prob_winning
          total += prob_winning
        end

        results[variants.last][:prob_winning] = 1 - total
      end
      results
    end

    def active?
      !winner
    end

    def closed?
      @closed
    end

    def keep_variant?
      @keep_variant
    end

    def control
      variants.first
    end

    def use_events?
      if @use_events.nil?
        FieldTest.events_supported?
      else
        @use_events
      end
    end

    def self.find(id)
      experiment = all.index_by(&:id)[id.to_s]
      raise FieldTest::ExperimentNotFound unless experiment

      experiment
    end

    def self.all
      FieldTest.config["experiments"].map do |id, settings|
        FieldTest::Experiment.new(settings.merge(id: id.to_s))
      end
    end

    private

    def check_participants(participants)
      raise FieldTest::UnknownParticipant, "Use the :participant option to specify a participant" if participants.empty?
    end

    # TODO fetch in single query
    def membership_for(participants)
      membership = nil
      participants.each do |participant|
        membership = self.memberships.find_by(participant.where_values)
        break if membership
      end
      membership
    end

    def weighted_variant
      total = weights.sum.to_f
      pick = rand
      n = 0
      weights.map { |w| w / total }.each_with_index do |w, i|
        n += w
        return variants[i] if n >= pick
      end
      variants.last
    end

    def cache_fetch(key)
      if FieldTest.cache
        Rails.cache.fetch(key.join("/")) { yield }
      else
        yield
      end
    end
  end
end
