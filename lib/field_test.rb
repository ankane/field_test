require "field_test/experiment"
require "field_test/engine"
require "field_test/helpers"
require "field_test/version"

module FieldTest
  class Error < StandardError; end
  class ExperimentNotFound < Error; end
end

ActiveSupport.on_load(:action_controller) do
  include FieldTest::Helpers
end

ActiveSupport.on_load(:action_view) do
  include FieldTest::Helpers
end

ActiveSupport.on_load(:action_mailer) do
  include FieldTest::Helpers
end
