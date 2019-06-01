module FieldTest
  module Helpers
    def field_test(experiment, options = {})
      exp = FieldTest::Experiment.find(experiment)

      participants = FieldTest::Participant.standardize(field_test_participant, options)

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

      participants = FieldTest::Participant.standardize(field_test_participant, options)

      exp.convert(participants, goal: options[:goal])
    end

    def field_test_experiments(options = {})
      participants = FieldTest::Participant.standardize(field_test_participant, options)
      experiments = {}
      participants.each do |participant|
        FieldTest::Membership.where(participant.where_values).each do |membership|
          experiments[membership.experiment] ||= membership.variant
        end
      end
      experiments
    end
  end
end
