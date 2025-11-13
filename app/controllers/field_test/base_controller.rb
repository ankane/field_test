module FieldTest
  class BaseController < ActionController::Base
    http_basic_authenticate_with name: ENV["FIELD_TEST_USERNAME"], password: ENV["FIELD_TEST_PASSWORD"] if ENV["FIELD_TEST_PASSWORD"]

    protect_from_forgery with: :exception

    layout "field_test/application"
  end
end
