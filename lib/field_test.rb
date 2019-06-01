# dependencies
require "active_support"
require "browser"
require "ipaddr"

# modules
require "field_test/calculations"
require "field_test/experiment"
require "field_test/helpers"
require "field_test/participant"
require "field_test/version"

# integrations
require "field_test/engine" if defined?(Rails)

module FieldTest
  class Error < StandardError; end
  class ExperimentNotFound < Error; end
  class UnknownParticipant < Error; end

  # same as ahoy
  UUID_NAMESPACE = "a82ae811-5011-45ab-a728-569df7499c5f"

  class << self
    attr_accessor :cookies, :legacy_participants
  end
  self.cookies = true

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

  def self.mask_ip(ip)
    addr = IPAddr.new(ip)
    if addr.ipv4?
      # set last octet to 0
      addr.mask(24).to_s
    else
      # set last 80 bits to zeros
      addr.mask(48).to_s
    end
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
