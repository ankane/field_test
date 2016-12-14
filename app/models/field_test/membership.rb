module FieldTest
  class Membership < ActiveRecord::Base
    self.table_name = "field_test_memberships"

    validates :participant, presence: true
    validates :experiment, presence: true
    validates :variant, presence: true
  end
end
