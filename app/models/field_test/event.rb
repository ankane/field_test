module FieldTest
  class Event < ActiveRecord::Base
    self.table_name = "field_test_events"

    belongs_to :field_test_membership, class_name: "FieldTest::Membership"
    validates :name, presence: true, uniqueness: { scope: :field_test_membership_id }
  end
end
