require_relative "test_helper"

class MailerTest < Minitest::Test
  def test_default
    UserMailer.welcome.deliver_now
    membership = FieldTest::Membership.last

    assert_equal 1, FieldTest::Membership.count
    assert membership.converted
  end
end
