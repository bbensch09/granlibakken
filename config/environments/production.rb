Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  #set action cable server URI
  # config.web_socket_server_url = "wss://snowschoolers-v2-2016.herokuapp.com/cable" 
  # config.web_socket_server_url = "wss://www.snowschoolers.com/cable" 

  #allowed request origins
  # config.action_cable.allowed_request_origins = [ 'http://localhost:3000','https://snowchoolers-v2-2016.herokuapp.com', '/http:\/\/snowchoolers-v2-2016.herokuapp.com.*/','https://wwww.snowschoolers.com', 'http://wwww.snowschoolers.com.*/' ]


  

  # Code is not reloaded between requests.
  config.cache_classes = true

  #force SSL on all pages when not run locally
  unless ENV['HOST_DOMAIN'] == "localhost:3000"
    # config.force_ssl = true
  end

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both thread web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  # config.action_dispatch.rack_cache = true


  # Disable serving static files from the `/public` folder by default since
	  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = true
  config.serve_static_assets = false

  # Generate digests for assets URLs.
  config.assets.digest = true

  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.0'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx
  # Mount Action Cable outside main process or domain
	# config.action_cable.mount_path = nil
	# config.action_cable.url = 'wss://example.com/cable'
	# config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]
  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Set to :debug to see everything in the log.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
  config.assets.precompile += %w( search.js )
  config.assets.precompile =  ['*.js', '*.scss']

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  config.action_mailer.raise_delivery_errors = true

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new


  #PAPERCLIP AWS S3 CONFIG
  config.paperclip_defaults = {
  :storage => :s3,
  :s3_region => ENV['AWS_REGION'],
  :s3_host_name => 's3.amazonaws.com',
  :bucket => 'snowschoolers'
  }

  #GMAIL CONFIG
  config.action_mailer.default_url_options = { :host => ENV['HOST_DOMAIN'] }
  config.action_mailer.delivery_method = :smtp
  # config.action_mailer.perform_deliveries = true
  config.action_mailer.perform_deliveries = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default :charset => "utf-8"
  config.action_mailer.smtp_settings = {
    address: "smtp.gmail.com",
    port: 587,
    domain: "lessons.granlibakken.com",
    authentication: "plain",
    enable_starttls_auto: true,
    user_name: "brian@snowschoolers.com",
    password: ENV["GMAIL_PASSWORD"]
  }

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end
  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
