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

    # test no metrics
    results = experiment.results
    experiment.convert("user123")
    assert_equal results, experiment.results
  end

  def test_variants
    experiment = FieldTest::Experiment.find(:button_color)
    assert_equal ["red", "green", "blue"], experiment.variants
    assert_equal "red", experiment.control
  end

  private

  def set_variant(experiment, variant, participant_id)
    FieldTest::Membership.create!(
      experiment: experiment.id,
      variant: variant,
      participant_id: participant_id
    )
  end
end
