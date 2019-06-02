class UserMailer < ApplicationMailer
  def welcome(user = nil)
    @user = user
    @button_color = field_test(:button_color)
    field_test_converted(:button_color)
    @experiments = field_test_experiments

    mail
  end
end
