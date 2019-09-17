require_relative 'boot'

require 'rails/all'
require  './app/middleware/middleware_healthcheck'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CmrMetadataReview
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.middleware.insert_after Rails::Rack::Logger, MiddlewareHealthcheck

    # Content Security Policy controls which javascript can be run in the
    # application with the goal of preventing Cross Site Scripting. The
    # parameter is new and legacy code will need to be updated. Change the
    # settings here to test your code under the new restrictions by commenting 
    # out the 'unsafe-inline' command. The goal is to be able to operate without
    # the 'unsafe-inline' command. If you must use a nonce then uncomment that
    # line and use the value indicated. To impliment a global default rule, use
    # the first line.
    policies = [
      #'default-src ' + ['\'self\''].join(' '),
      'script-src-elem ' + ['\'self\'',
        "\'unsafe-inline\'",
        #"\'nonce-view012345\'",
        "www.google-analytics.com",
        "fbm.earthdata.nasa.gov",
        "cdn.earthdata.nasa.gov"].join(' ')
    ]
    config.action_dispatch.default_headers.merge!( 'Content-Security-Policy' => policies.join("; ") )

    def load_version
      version_file = "#{config.root}/version.txt"
      if File.exist?(version_file)
        return IO.read(version_file)
      elsif File.exist?('.git/config') && `which git`.size > 0
        version = `git rev-parse --short HEAD`
        return version.strip
      end
      '(unknown)'
    end

    config.version = load_version
  end
end
