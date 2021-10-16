require_relative "test_helper"

class ProbWinningTest < Minitest::Test
  def setup
    FieldTest::Membership.delete_all
  end

  def test_two_variants
    experiment = FieldTest::Experiment.find(:button_color2)
    50.times do |i|
      variant = i < 35 ? "red" : "green"
      set_variant experiment, variant, "user#{i}"
      experiment.convert("user#{i}") if i < 10 || i % 3 == 0
    end
    results = experiment.results
    assert_in_delta 0.8722609845723905, results["red"][:prob_winning]
    assert_in_delta 0.12773901542760946, results["green"][:prob_winning]
  end

  def test_three_variants
    experiment = FieldTest::Experiment.find(:button_color)
    50.times do |i|
      variant = i < 25 ? "red" : (i < 40 ? "green" : "blue")
      set_variant experiment, variant, "user#{i}"
      experiment.convert("user#{i}") if i < 10 || i % 3 == 0 || i > 47
    end
    results = experiment.results
    assert_in_delta 0.8156540600702418, results["red"][:prob_winning]
    assert_in_delta 0.04309667172308218, results["green"][:prob_winning]
    assert_in_delta 0.14124926820667605, results["blue"][:prob_winning]
  end

  def test_two_variants_no_participants
    experiment = FieldTest::Experiment.find(:button_color2)
    experiment.results.each do |_, v|
      assert_in_delta 0.5, v[:prob_winning]
    end
  end

  def test_three_variants_no_participants
    experiment = FieldTest::Experiment.find(:button_color)
    experiment.results.each do |_, v|
      assert_in_delta 0.3333333333333333, v[:prob_winning]
    end
  end

  def test_cache
    experiment = FieldTest::Experiment.find(:button_color2)
    set_variant experiment, "red", "user123"

    FieldTest.stub(:cache, true) do
      experiment.results
    end

    probabilities = Rails.cache.fetch("field_test/probabilities/1/0/0/0")
    assert_in_delta 0.3333333333333333, probabilities[0]
    assert_in_delta 0.6666666666666667, probabilities[1]
  end
end
