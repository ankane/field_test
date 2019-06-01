class UserMailer < ApplicationMailer
  def welcome
    p field_test(:button_color)
  end
end
