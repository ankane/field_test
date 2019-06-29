require_relative "test_helper"

class ExperimentTest < Minitest::Test
  def test_winner
    experiment = FieldTest::Experiment.find(:landing_page)
    assert_equal experiment.winner, experiment.variant("user123")
  end
end
