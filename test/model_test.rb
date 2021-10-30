require_relative "test_helper"

class ModelTest < Minitest::Test
  def setup
    FieldTest::Membership.delete_all
  end

  def test_membership_with_event
    experiment = FieldTest::Experiment.find(:landing_page)
    membership = set_variant experiment, "page_a", "user123"
    event = FieldTest::Event.create!(
      name: "conversion",
      field_test_membership_id: membership.id
    )

    puts "*** the sql"
    puts membership.events.to_sql
    assert_equal membership, event.field_test_membership
    assert_equal 1, membership.events.count
    assert_equal event, membership.events.first
  end
end
