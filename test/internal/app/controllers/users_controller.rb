class UsersController < ActionController::Base
  def index
    @button_color = field_test(:button_color)
    field_test_converted(:button_color)
    @experiments = field_test_experiments
  end
end
