module FieldTest
  class Membership < ActiveRecord::Base
    self.table_name = "field_test_memberships"

    has_many :events, class_name: "FieldTest::Event", foreign_key: "field_test_membership_id"

    unless FieldTest.legacy_participants
      belongs_to :participant, polymorphic: true, optional: true
    end

    validates :participant, presence: true, if: -> { FieldTest.legacy_participants }
    validates :participant_id, presence: true, if: -> { !FieldTest.legacy_participants }
    validates :experiment, presence: true
    validates :variant, presence: true
  end
end
