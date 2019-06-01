module FieldTest
  class Membership < ActiveRecord::Base
    self.table_name = "field_test_memberships"

    has_many :events, class_name: "FieldTest::Event"

    validates :participant, presence: true, if: -> { FieldTest.legacy_participants }
    validates :participant_id, presence: true, if: -> { !FieldTest.legacy_participants }
    validates :experiment, presence: true
    validates :variant, presence: true
  end
end
