module FieldTest
  module Helpers
    def field_test(experiment, options = {})
      exp = FieldTest::Experiment.find(experiment)

      participants = field_test_participants(options)

      if try(:request)
        if params[:field_test] && params[:field_test][experiment]
          options[:variant] ||= params[:field_test][experiment]
        end

        if FieldTest.exclude_bots?
          options[:exclude] = Browser.new(request.user_agent).bot?
        end

        options[:ip] = request.remote_ip
        options[:user_agent] = request.user_agent
      end

      # cache results for request
      @field_test_cache ||= {}
      @field_test_cache[experiment] ||= exp.variant(participants, options)
    end

    def field_test_converted(experiment, options = {})
      exp = FieldTest::Experiment.find(experiment)

      participants = field_test_participants(options)

      exp.convert(participants, goal: options[:goal])
    end

    def field_test_experiments(options = {})
      participants = field_test_participants(options)
      memberships = FieldTest::Membership.where(participant: participants).group_by(&:participant)
      experiments = {}
      participants.each do |participant|
        memberships[participant].to_a.each do |membership|
          experiments[membership.experiment] ||= membership.variant
        end
      end
      experiments
    end

    def field_test_participants(options = {})
      participants = []

      if options[:participant]
        participants << options[:participant]
      else
        if respond_to?(:current_member, true) && current_member
          participants << current_member
        end

        # controllers and views
        if try(:request)
          # use cookie
          cookie_key = "field_test"

          token = cookies[cookie_key]
          token = token.gsub(/[^a-z0-9\-]/i, "") if token

          if participants.empty? && !token
            token = SecureRandom.uuid
            cookies[cookie_key] = {value: token, expires: 30.days.from_now}
          end
          if token
            participants << token

            # backwards compatibility
            participants << "cookie:#{token}"
          end
        end

        # mailers
        to = try(:message).try(:to).try(:first)
        if to
          participants << to
        end
      end

      FieldTest::Participant.standardize(participants)
    end
  end
end
