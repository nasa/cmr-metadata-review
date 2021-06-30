# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
SimpleCov.start 'rails'

require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'
require 'mocha/minitest'
require 'minitest/mock'
require 'webmock/minitest'
require 'minitest/reporters'

# Not sure this is the best thing to do, but we don't call localhost for anything needed in our tests.
WebMock.disable_net_connect!(
   allow_localhost: true,
   allow: 'chromedriver.storage.googleapis.com'
)

require 'minitest/rails/capybara'

Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new, Minitest::Reporters::JUnitReporter.new]

# Specs flagged with `js: true` will use Capybara's JS driver.
Capybara.register_driver :headless_chrome do |app|
  # set timeout to 60s http://www.testrisk.com/2016/05/change-default-timeout-and-wait-time-of.html
  # need to use read_timeout and open_timeout https://github.com/SeleniumHQ/selenium/blob/master/rb/lib/selenium/webdriver/remote/http/default.rb
  client = Selenium::WebDriver::Remote::Http::Default.new
  client.read_timeout = 60
  client.open_timeout = 60

  # http://technopragmatica.blogspot.com/2017/10/switching-to-headless-chrome-for-rails_31.html
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    # This makes javascript console logs available, but doesn't cause them to appear in real time
    # to display javascript logs in the rspec output, add `puts page.driver.browser.manage.logs.get(:browser)`
    # in the desired test location
    # w3c: false is needed for retrieving javascript console messages.
    loggingPrefs: { browser: 'ALL', client: 'ALL', driver: 'ALL', server: 'ALL' },
    chromeOptions: { args: %w[headless disable-gpu no-sandbox --window-size=1500,2000], w3c: false}

  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, http_client: client, desired_capabilities: capabilities)
end

Capybara::Screenshot.register_driver(:headless_chrome) do |driver, path|
  driver.browser.save_screenshot(path)
end

# setting headless_chrome as default driver, can be changed to run not headless
Capybara.default_driver = :headless_chrome
Capybara.javascript_driver = :headless_chrome

# WebMock.allow_net_connect!
WebMock.after_request(real_requests_only: true) do |request_signature, response|
  unless request_signature.uri.to_s.include?('127.0.0.1') || request_signature.uri.to_s.include?('chromedriver.storage.googleapis.com')
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

# new way for rails 6+ to control browser options
class SystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1500,2000]
end

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)
