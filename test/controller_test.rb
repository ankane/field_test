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

  def test_param
    get users_url("field_test[button_color]" => "green")
    assert_response :success

    assert_includes response.body, "Button: green"
    assert_equal 0, FieldTest::Membership.count
  end

  def test_exclude_bots
    get users_url, headers: {"HTTP_USER_AGENT" => "Googlebot"}
    assert_response :success

    assert_equal 0, FieldTest::Membership.count
  end
end
