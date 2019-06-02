module FieldTest
  module Controller
    extend ActiveSupport::Concern
    include Helpers

    included do
      if respond_to?(:helper_method)
        helper_method :field_test
        helper_method :field_test_converted
        helper_method :field_test_experiments
      end
    end

    private

    def field_test_participant
      participants = []

      if respond_to?(:current_user, true)
        user = send(:current_user)
        participants << user if user
      end

      cookie_key = "field_test"
      if FieldTest.cookies
        token = cookies[cookie_key]
        token = token.gsub(/[^a-z0-9\-]/i, "") if token

        if participants.empty? && !token
          token = SecureRandom.uuid
          cookies[cookie_key] = {value: token, expires: 30.days.from_now}
        end
      else
        # anonymity set
        token = Digest::UUID.uuid_v5(FieldTest::UUID_NAMESPACE, ["visitor", FieldTest.mask_ip(request.remote_ip), request.user_agent].join("/"))

        # delete cookie if present
        cookies.delete(cookie_key) if cookies[cookie_key]
      end

      if token
        participants << token

        # backwards compatibility
        participants << "cookie:#{token}" if FieldTest.legacy_participants
      end

      participants
    end
  end
end
