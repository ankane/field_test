require_relative "test_helper"

class ControllerTest < ActionDispatch::IntegrationTest
  def setup
    FieldTest::Membership.delete_all
    User.delete_all
  end

  def test_no_user
    get users_url
    assert_response :success

    membership = FieldTest::Membership.last
    assert_equal 1, FieldTest::Membership.count
    assert membership.converted
    assert_nil membership.participant_type
    assert membership.participant_id
  end

  def test_user
    user = User.create!

    get users_url
    assert_response :success

    membership = FieldTest::Membership.last
    assert_equal 1, FieldTest::Membership.count
    assert membership.converted
    assert_equal "User", membership.participant_type
    assert_equal user.id.to_s, membership.participant_id
  end
end
