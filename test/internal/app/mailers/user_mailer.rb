class UserMailer < ApplicationMailer
  def welcome
    @user = User.create!

    @button_color = field_test(:button_color)
    field_test_converted(:button_color)
    @experiments = field_test_experiments

    mail
  end
end
