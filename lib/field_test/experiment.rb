module FieldTest
  class Experiment
    attr_reader :id, :name, :variants, :winner, :started_at, :ended_at

    def initialize(attributes)
      attributes = attributes.symbolize_keys
      @id = attributes[:id]
      @name = attributes[:name] || @id.to_s.titleize
      @variants = attributes[:variants]
      @winner = attributes[:winner]
      @started_at = Time.zone.parse(attributes[:started_at].to_s) if attributes[:started_at]
      @ended_at = Time.zone.parse(attributes[:ended_at].to_s) if attributes[:ended_at]
    end

    def variant(participants, options = {})
      return winner if winner
      return variants.first if options[:exclude]

      participants = FieldTest::Participant.standardize(participants)
      membership = membership_for(participants) || FieldTest::Membership.new(experiment: id)

      if options[:variant] && variants.include?(options[:variant])
        membership.variant = options[:variant]
      else
        membership.variant ||= variants.sample
      end

      # upgrade to preferred participant
      membership.participant = participants.first

      if membership.changed?
        begin
          membership.save!
        rescue ActiveRecord::RecordNotUnique
          membership = memberships.find_by(participant: participants.first)
        end
      end

      membership.try(:variant) || variants.first
    end

    def convert(participants)
      participants = FieldTest::Participant.standardize(participants)
      membership = membership_for(participants)

      if membership
        membership.converted = true
        membership.save! if membership.changed?
        true
      else
        false
      end
    end

    def memberships
      FieldTest::Membership.where(experiment: id)
    end

    def results
      data = memberships.group(:variant).group(:converted)
      data = data.where("created_at >= ?", started_at) if started_at
      data = data.where("created_at <= ?", ended_at) if ended_at
      data = data.count
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
      when 1
        results[variants[0]][:prob_winning] = 1
      when 2, 3
        variants.size.times do |i|
          c = results.values[i]
          b = results.values[(i + 1) % variants.size]
          a = results.values[(i + 2) % variants.size]

          alpha_a = 1 + a[:converted]
          beta_a = 1 + a[:participated] - a[:converted]
          alpha_b = 1 + b[:converted]
          beta_b = 1 + b[:participated] - b[:converted]
          alpha_c = 1 + c[:converted]
          beta_c = 1 + c[:participated] - c[:converted]

          results[variants[i]][:prob_winning] =
            if variants.size == 2
              prob_b_beats_a(alpha_b, beta_b, alpha_c, beta_c)
            else
              prob_c_beats_a_and_b(alpha_a, beta_a, alpha_b, beta_b, alpha_c, beta_c)
            end
        end
      end
      results
    end

    def active?
      !winner
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

      def membership_for(participants)
        memberships = self.memberships.where(participant: participants).index_by(&:participant)
        participants.map { |part| memberships[part] }.compact.first
      end

      # formula from
      # http://www.evanmiller.org/bayesian-ab-testing.html
      def prob_b_beats_a(alpha_a, beta_a, alpha_b, beta_b)
        total = 0.0

        0.upto(alpha_b - 1) do |i|
          total += Math.exp(Math.logbeta(alpha_a + i, beta_b + beta_a) -
            Math.log(beta_b + i) - Math.logbeta(1 + i, beta_b) -
            Math.logbeta(alpha_a, beta_a))
        end

        total
      end

      def prob_c_beats_a_and_b(alpha_a, beta_a, alpha_b, beta_b, alpha_c, beta_c)
        total = 0.0
        0.upto(alpha_a - 1) do |i|
          0.upto(alpha_b - 1) do |j|
            total += Math.exp(Math.logbeta(alpha_c + i + j, beta_a + beta_b + beta_c) -
              Math.log(beta_a + i) - Math.log(beta_b + j) -
              Math.logbeta(1 + i, beta_a) - Math.logbeta(1 + j, beta_b) -
              Math.logbeta(alpha_c, beta_c))
          end
        end

        1 - prob_b_beats_a(alpha_c, beta_c, alpha_a, beta_a) -
          prob_b_beats_a(alpha_c, beta_c, alpha_b, beta_b) + total
      end
  end
end
