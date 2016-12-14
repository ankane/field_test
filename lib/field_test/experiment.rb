module FieldTest
  class Experiment
    attr_reader :id, :variants, :winner

    def initialize(attributes)
      attributes = attributes.symbolize_keys
      @id = attributes[:id]
      @variants = attributes[:variants]
      @winner = attributes[:winner]
    end

    def variant(participants, options = {})
      return winner if winner
      return variants.first if options[:exclude]

      participants = standardize_participants(participants)
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
      participants = standardize_participants(participants)
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
      data = memberships.group(:variant).group(:converted).count
      results = {}
      variants.each do |variant|
        converted = data[[variant, true]].to_i
        participated = converted + data[[variant, false]].to_i
        results[variant] = {
          participated: participated,
          converted: converted,
          conversion_rate: converted.to_f / participated
        }
      end
      results
    end

    def self.find(id)
      # reload in dev
      @config = nil if Rails.env.development?

      @config ||= YAML.load(ERB.new(File.read("config/field_test.yml")).result)

      settings = @config["experiments"][id.to_s]
      raise FieldTest::ExperimentNotFound unless settings

      FieldTest::Experiment.new(settings.merge(id: id.to_s))
    end

    private

      def membership_for(participants)
        memberships = self.memberships.where(participant: participants).index_by(&:participant)
        participants.map { |part| memberships[part] }.compact.first
      end

      def standardize_participants(participants)
        Array(participants).map { |v| v.respond_to?(:model_name) ? "#{v.model_name.name}:#{v.id}" : v.to_s }
      end
  end
end
