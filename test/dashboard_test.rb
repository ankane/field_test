require_relative "test_helper"

class DashboardTest < ActionDispatch::IntegrationTest
  def test_root
    get field_test_engine.root_path
    assert_response :success
  end
end
