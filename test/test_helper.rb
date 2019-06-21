ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
SimpleCov.start 'rails'

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/minitest'
require 'minitest/mock'
require 'webmock/minitest'
require 'minitest/reporters'
require 'minitest/rails/capybara'

Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new, Minitest::Reporters::JUnitReporter.new]

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w[headless disable-gpu --window-size=1500,1500] }
  )

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: capabilities
  )
end

# setting headless_chrome as default driver, can be changed to run not headless
Capybara.default_driver = :headless_chrome
Capybara.javascript_driver = :headless_chrome
# Not sure this is the best thing to do, but we don't call localhost for anything needed in our tests.
WebMock.disable_net_connect!(allow_localhost: true)
# WebMock.allow_net_connect!
WebMock.after_request(real_requests_only: true) do |request_signature, response|
  unless request_signature.uri.to_s.include?('127.0.0.1')
    puts "Request #{request_signature} was made. \nrequest headers=#{request_signature.headers}\nresponse body=#{response.body}"
  end
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  #
  #
  def get_stub(file_name)
    file = "#{Rails.root}/test/stubs/#{file_name}"
    File.read(file)
  end
end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers
  OmniAuth.config.test_mode = true
end

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

