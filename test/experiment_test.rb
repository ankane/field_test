require_relative "test_helper"

class ExperimentTest < Minitest::Test
  def setup
    FieldTest::Membership.delete_all
  end

  def test_winner
    experiment = FieldTest::Experiment.find(:landing_page)
    assert_equal experiment.winner, experiment.variant("user123")
    assert_equal 0, FieldTest::Membership.count
  end

  def test_winner_existing_participant
    experiment = FieldTest::Experiment.find(:landing_page)
    set_variant experiment, "page_a", "user123"
    assert_equal experiment.winner, experiment.variant("user123")
  end

  private

  def set_variant(experiment, variant, participant_id)
    FieldTest::Membership.create!(
      experiment: experiment.name,
      variant: variant,
      participant_id: participant_id
    )
  end
end
