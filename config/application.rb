require_relative 'boot'

require 'rails/all'
require  './app/middleware/middleware_healthcheck'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Details on upgrading to omniauth 2.0 are here:
# https://github.com/omniauth/omniauth/wiki/Upgrading-to-2.0
# Derived from https://github.com/cookpad/omniauth-rails_csrf_protection/blob/master/lib/omniauth/rails_csrf_protection/token_verifier.rb
# This specific implementation has been pared down and should not be taken as the most correct way to do this.
class TokenVerifier
  include ActiveSupport::Configurable
  include ActionController::RequestForgeryProtection

  def call(env)
    @request = ActionDispatch::Request.new(env.dup)
    raise OmniAuth::AuthenticityError unless verified_request?
  end

  private
  attr_reader :request
  delegate :params, :session, to: :request
end

module CmrMetadataReview
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    # https://stackoverflow.com/questions/50102584/upgrading-rails-what-am-i-to-do-with-new-framework-defaults-file
    config.load_defaults 5.2

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

    # config.session_store :cookie_store, key: '_interslice_session'
    # config.middleware.use ActionDispatch::Cookies # Required for all session management
    # config.middleware.use ActionDispatch::Session::CookieStore, config.session_options

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

    OmniAuth.config.request_validation_phase = ::TokenVerifier.new
  end
end
