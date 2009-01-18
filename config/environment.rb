# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.2.6' unless defined? RAILS_GEM_VERSION

# Override default authorization system constants here.
AUTHORIZATION_MIXIN = "object roles"
DEFAULT_REDIRECTION_HASH = { :controller => 'session', :action => 'new' }
STORE_LOCATION_METHOD = :store_location

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

require 'redcloth'
require 'app_config'

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  config.load_paths += %W( #{RAILS_ROOT}/app/navigation )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile

# Include your application configuration below

# Pick a unique cookie name to distinguish our session data from others'
ActionController::Base.session_options[:session_key] = "_collecticus_session_id"

# Exception notification
ExceptionNotifier.exception_recipients = %(support@nthmetal.com)
ExceptionNotifier.sender_address = %("Application Error" <errors@collectic.us>)
ExceptionNotifier.email_prefix = "[collectic.us] "

# Status (release update) notification
StatusNotifier.status_recipients = %(support@nthmetal.com)
StatusNotifier.sender_address = %("Application Status" <status@collectic.us>)
StatusNotifier.email_prefix = "[collectic.us] "

# Enable hard breaks in RedCloth
class RedCloth
  def hard_breaks; true; end
end
