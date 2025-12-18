require "bundler/setup"
require "combustion"
Bundler.require(:default)
require "minitest/autorun"

logger = ActiveSupport::Logger.new(ENV["VERBOSE"] ? STDOUT : nil)

Combustion.path = "test/internal"
Combustion.initialize! :active_record, :action_controller, :action_mailer do
  config.load_defaults Rails::VERSION::STRING.to_f

  config.active_record.logger = logger
  config.action_mailer.logger = logger
end

class Minitest::Test
  def set_variant(experiment, variant, participant_id)
    FieldTest::Membership.create!(
      experiment: experiment.id,
      variant: variant,
      participant_id: participant_id
    )
  end

  def with_config(config)
    FieldTest.config.merge!(config)
    yield
  ensure
    FieldTest.remove_instance_variable(:@config)
  end
end
