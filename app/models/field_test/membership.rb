module FieldTest
  class Membership < ActiveRecord::Base
    self.table_name = "field_test_memberships"

    has_many :events, class_name: "FieldTest::Event"

    validates :participant, presence: true
    validates :experiment, presence: true, uniqueness: { scope: :participant }
    validates :variant, presence: true
  end
end
