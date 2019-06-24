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
    loggingPrefs: { browser: 'ALL', client: 'ALL', driver: 'ALL', server: 'ALL' }
  )

  # disable-gpu option is temporarily necessary, possibly only for Windows
  # https://developers.google.com/web/updates/2017/04/headless-chrome#cli
  # no-sandbox was necessary for another application's Docker container for CI/CD
  # https://about.gitlab.com/2017/12/19/moving-to-headless-chrome/
  # https://developers.google.com/web/updates/2017/04/headless-chrome#faq
  options = Selenium::WebDriver::Chrome::Options.new(
    args: %w[headless disable-gpu no-sandbox --window-size=1500,1500]
  )

  Capybara::Selenium::Driver.new(app, browser: :chrome, http_client: client, desired_capabilities: capabilities, options: options)
end

# setting headless_chrome as default driver, can be changed to run not headless
Capybara.default_driver = :headless_chrome
Capybara.javascript_driver = :headless_chrome
# Not sure this is the best thing to do, but we don't call localhost for anything needed in our tests.

WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: 'chromedriver.storage.googleapis.com'
)
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
