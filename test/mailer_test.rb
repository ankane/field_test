require_relative "test_helper"

class MailerTest < Minitest::Test
  def test_default
    message = UserMailer.welcome.deliver_now
    p FieldTest::Membership.all.to_a
  end
end
