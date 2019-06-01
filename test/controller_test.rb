require_relative "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def test_works
    get users_url
    assert_response :success
  end
end
