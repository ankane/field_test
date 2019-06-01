require_relative "test_helper"

class CalculationsTest < Minitest::Test
  def test_prob_b_beats_a
    assert_prob_b_beats_a 0.6428571428571429, [1, 2, 3, 4]
    assert_prob_b_beats_a 0.38386463776317903, [55, 50, 30, 30]
    assert_prob_b_beats_a 0.6867997222295887, [50, 50, 35, 30]
  end

  def test_prob_c_beats_a_and_b
    assert_prob_c_beats_a_and_b 0.4128959276018096, [1, 2, 3, 4, 5, 6]
    assert_prob_c_beats_a_and_b 0.0004147782900546515, [1, 2, 3, 4, 5, 100]
    assert_prob_c_beats_a_and_b 0.35421204276865736, [55, 50, 30, 30, 10, 10]
    assert_prob_c_beats_a_and_b 0.09139305107602524, [50, 50, 35, 30, 13, 18]
  end

  private

  def assert_prob_b_beats_a(expected, args)
    assert_in_delta expected, FieldTest::Calculations.prob_b_beats_a(*args), 0.0000000001
  end

  def assert_prob_c_beats_a_and_b(expected, args)
    assert_in_delta expected, FieldTest::Calculations.prob_c_beats_a_and_b(*args), 0.0000000001
  end
end
