module FieldTest
  class Membership < ActiveRecord::Base
    self.table_name = "field_test_memberships"

    has_many :events, class_name: "FieldTest::Event"

    belongs_to :participant, polymorphic: true

    validates :participant_type, presence: true
    validates :participant_id, presence: true
    validates :experiment, presence: true
    validates :variant, presence: true
  end
end
