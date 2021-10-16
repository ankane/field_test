require "bundler/setup"
require "combustion"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"

logger = ActiveSupport::Logger.new(ENV["VERBOSE"] ? STDOUT : nil)

Combustion.path = "test/internal"
Combustion.initialize! :active_record, :action_controller, :action_mailer do
  if ActiveRecord::VERSION::MAJOR < 6 && config.active_record.sqlite3.respond_to?(:represent_boolean_as_integer)
    config.active_record.sqlite3.represent_boolean_as_integer = true
  end

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
end
