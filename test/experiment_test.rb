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

  def test_winner_keep_variant
    experiment = FieldTest::Experiment.find(:landing_page2)
    set_variant experiment, "page_a", "user123"
    assert_equal "page_a", experiment.variant("user123")
  end

  def test_closed
    experiment = FieldTest::Experiment.find(:landing_page3)
    assert_equal experiment.control, experiment.variant("user123")
    assert_equal 0, FieldTest::Membership.count
  end

  def test_closed_existing_participant
    experiment = FieldTest::Experiment.find(:landing_page3)
    set_variant experiment, "page_a", "user123"
    assert_equal "page_a", experiment.variant("user123")
  end

  def test_goals
    experiment = FieldTest::Experiment.find(:landing_page4)
    assert experiment.multiple_goals?
    assert_equal ["signed_up", "ordered"], experiment.goals

    12.times do |i|
      set_variant experiment, "page_a", "user#{i}"
      if i % 2 == 0
        experiment.convert("user#{i}", goal: "signed_up")
      end
      if i % 4 == 0
        experiment.convert("user#{i}", goal: "ordered")
      end
    end

    result = experiment.results(goal: "signed_up")["page_a"]
    assert_equal 12, result[:participated]
    assert_equal 6, result[:converted]
    assert_equal 0.5, result[:conversion_rate]
    assert_in_delta 0.2667, result[:prob_winning]

    result = experiment.results(goal: "ordered")["page_a"]
    assert_equal 12, result[:participated]
    assert_equal 3, result[:converted]
    assert_equal 0.25, result[:conversion_rate]
    assert_in_delta 0.0952, result[:prob_winning]
  end

  def test_variants
    experiment = FieldTest::Experiment.find(:button_color)
    assert_equal ["red", "green", "blue"], experiment.variants
    assert_equal "red", experiment.control
  end
end
