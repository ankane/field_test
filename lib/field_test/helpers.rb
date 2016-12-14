module FieldTest
  module Helpers
    def field_test(experiment, options = {})
      exp = FieldTest::Experiment.find(experiment)

      participants = field_test_participants(options)

      if try(:request)
        if params[:field_test] && params[:field_test][experiment]
          options[:variant] ||= params[:field_test][experiment]
        end
      end

      # cache results for request
      @field_test_cache ||= {}
      @field_test_cache[experiment] ||= exp.variant(participants, options)
    end

    def field_test_converted(experiment, options = {})
      exp = FieldTest::Experiment.find(experiment)

      participants = field_test_participants(options)

      exp.convert(participants)
    end

    def field_test_participants(options = {})
      participants = []

      if options[:participant]
        participants << options[:participant]
      else
        if respond_to?(:current_user, true) && current_user
          participants << current_user
        end

        if try(:request)
          # use cookie
          cookie_key = "field_test"
          token = cookies[cookie_key]
          if participants.empty? && !token
            token = SecureRandom.uuid
            cookies[cookie_key] = {value: token, expires: 30.days.from_now}
          end
          if token
            participants << "cookie:#{token.gsub(/[^a-z0-9\-]/i, "")}"
          end
        end
      end

      participants
    end
  end
end
