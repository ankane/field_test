module FieldTest
  module Mailer
    extend ActiveSupport::Concern
    include Helpers

    included do
      helper_method :field_test_participant
    end

    def field_test_participant
      @user || params[:user]
    end
  end
end
