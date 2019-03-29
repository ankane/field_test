require "browser"
require "active_support"
require "field_test/calculations"
require "field_test/experiment"
require "field_test/engine" if defined?(Rails)
require "field_test/helpers"
require "field_test/participant"
require "field_test/version"

module FieldTest
  class Error < StandardError; end
  class ExperimentNotFound < Error; end
  class UnknownParticipant < Error; end

  def self.config
    # reload in dev
    @config = nil if Rails.env.development?

    @config ||= YAML.load(ERB.new(File.read("config/field_test.yml")).result)
  end

  def self.exclude_bots?
    config = self.config # dev performance
    config["exclude"] && config["exclude"]["bots"]
  end

  def self.cache
    config["cache"]
  end

  def self.precision
    config["precision"] || 0
  end

  def self.events_supported?
    unless defined?(@events_supported)
      connection = FieldTest::Membership.connection
      table_name = "field_test_events"
      @events_supported =
        if connection.respond_to?(:data_source_exists?)
          connection.data_source_exists?(table_name)
        else
          connection.table_exists?(table_name)
        end
    end
    @events_supported
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
