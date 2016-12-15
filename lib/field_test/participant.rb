module FieldTest
  class Participant
    def self.standardize(participants)
      Array(participants).map { |v| v.respond_to?(:model_name) ? "#{v.model_name.name}:#{v.id}" : v.to_s }
    end
  end
end
