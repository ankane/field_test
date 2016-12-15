require "distribution/math_extension"
require "field_test/experiment"
require "field_test/engine"
require "field_test/helpers"
require "field_test/version"

module FieldTest
  class Error < StandardError; end
class ExperimentNotFound < Error; end

def self.config
    # reload in dev
    @config = nil if Rails.env.development?

    @config ||= YAML.load(ERB.new(File.read("config/field_test.yml")).result)
  end
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
