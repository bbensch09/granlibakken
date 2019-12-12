require_relative 'boot'
# require 'rails/all' #this includes action cable code, which decided to remove on 11-24
require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"
require 'csv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# ActiveSupport.halt_callback_chains_on_return_false = false

module SnowSchoolers
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Pacific Time (US & Canada)'
    config.active_record.default_timezone = :local

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de


  #LOAD all files in library
  config.autoload_paths << Rails.root.join('lib')

  #autoload classes such as GoogleAnalyticsAPI even in production mode.
  config.enable_dependency_loading = true
  config.autoload_paths << Rails.root.join('lib')

  # # attempted patch 10.6.19 for cyper secret https://github.com/rails/rails/issues/25448
  # secret = ENV['SECRET_KEY'] # this represent a 64 chars key used on ruby 2.3
  # encryptor = ActiveSupport::MessageEncryptor.new(secret[0..31], secret)
  # encryptor.decrypt_and_verify(data)

  #LOAD local ENV variables
    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'local_secrets.yml')
      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
            end if File.exists?(env_file)
        end

  end

end
