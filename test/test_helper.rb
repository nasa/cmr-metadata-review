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

#Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new, Minitest::Reporters::JUnitReporter.new]

Selenium::WebDriver.logger.output = false

# Not sure this is the best thing to do, but we don't call localhost for anything needed in our tests.
allow_list = ['127.0.0.1', 'storage.googleapis.com', 'googlechromelabs.github.io', 'edgedl.me.gvt1.com', 'chromedriver.storage.googleapis.com']
WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: allow_list
)

# setting headless_chrome as default driver, can be changed to run not headless
Capybara.default_driver = :headless_chrome
Capybara.javascript_driver = :headless_chrome

WebMock.after_request(real_requests_only: true) do |request_signature, response|
  allowed = true
  allow_list.each do |host|
    allowed = false if request_signature.uri.to_s.include?(host)
  end
  if allowed
    puts "Request #{request_signature} was made. \nrequest headers=#{request_signature.headers}\nresponse body=#{response.body}"
  end
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  # Add more helper methods to be used by all tests here...

  def get_stub(file_name)
    file = "#{Rails.root}/test/stubs/#{file_name}"
    File.read(file)
  end
end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers
  OmniAuth.config.test_mode = true
end

class SystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1500,2000] do |options|
    options.add_argument("headless")
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-gpu')
  end
end

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_all_pending! if defined?(ActiveRecord::Migration)
