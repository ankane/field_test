module FieldTest
  class Participant
    def self.standardize(participants)
      Array(participants).map { |v| v.is_a?(String) ? v.to_s : "#{v.class.name}:#{v.id}" }
    end
  end
end
