require_relative "boot"

require "rails"

# Only the frameworks we actually use
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "active_job/railtie"

Bundler.require(*Rails.groups)

module HealthcareAppointmentSystem
  class Application < Rails::Application
    config.load_defaults 7.1
    config.api_only = true
    config.autoload_lib(ignore: %w[assets tasks])
    config.time_zone = "UTC"
    config.active_record.default_timezone = :utc
  end
end
