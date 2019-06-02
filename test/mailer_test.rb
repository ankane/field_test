require_relative "test_helper"

class MailerTest < Minitest::Test
  def setup
    FieldTest::Membership.delete_all
    User.delete_all
  end

  def test_basic
    user = User.create!
    UserMailer.with(user: user).welcome.deliver_now

    membership = FieldTest::Membership.last
    assert_equal 1, FieldTest::Membership.count
    assert membership.converted
    assert_equal "User", membership.participant_type
    assert_equal user.id.to_s, membership.participant_id
  end

  def test_user_string
    participant = "123"
    UserMailer.with(user: participant).welcome.deliver_now

    membership = FieldTest::Membership.last
    assert_equal 1, FieldTest::Membership.count
    assert membership.converted
    assert_nil membership.participant_type
    assert_equal participant, membership.participant_id
  end

  def test_no_user
    assert_raises FieldTest::UnknownParticipant do
      UserMailer.welcome.deliver_now
    end
  end
end
