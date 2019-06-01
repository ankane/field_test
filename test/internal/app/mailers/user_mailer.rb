class UserMailer < ApplicationMailer
  def welcome
    @user = User.create!
    p field_test_participant
    p field_test(:button_color)
  end
end
