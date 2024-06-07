source 'https://rubygems.org'
ruby "3.0.6"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.0.8.3'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '1.7.3', group: [:test]
# use pg for local and prod development
gem 'pg', group: [:test, :development, :production]

gem "shakapacker", "6.5"
gem "react-rails", "2.6"

gem 'sprockets-rails'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 6.0'

gem 'bourbon'
gem 'neat'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 5.0.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder' #, '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 2.3.1.0', group: :doc

gem 'httparty', '~> 0.21.0'
gem 'aasm', '~> 4.12.0'

gem 'rubyXL'
gem 'ruby-progressbar'
gem 'dotenv-rails'

group :test do
  gem 'webmock'
  gem 'mocha'
  gem 'minitest-reporters'
  gem 'minitest-rails'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'launchy'
  gem 'capybara-screenshot'
  gem 'minitest-stub_any_instance'
  gem 'rspec-rails'
end

group :development, :test do
  gem 'pry-rails'
  gem 'pry-byebug'
end

#coverage map for testing
gem 'simplecov', :require => false, :group => :test

#using puma server instead of webBrick
gem 'puma', '~> 6.4.2'
gem 'puma-daemon', require: false
#base authentication gem
gem 'devise'
#setting user permissions for pages
gem 'cancancan'

#js runtime
gem 'execjs', '~> 2.7.0'
#communication with aws S3 & other utils
gem 'aws-sdk', '~> 3.0.0'

# Should use 5.0.13 but compatibility issues with SIT version of RH, has older GCC.    Eventualaly when they upgrade RH, we can move back to the latest
gem 'font-awesome-sass', '>= 5.15.1'
gem 'font-awesome-rails', '>= 4.7.0.7'
#gem 'activerecord', '~> 6.1'
gem 'activerecord-session_store'#, '2.0.0'
gem 'whenever', require: false
gem 'oauth2'
gem 'omniauth-oauth2'
gem 'faraday_middleware', '1.2.0'

gem 'omniauth-urs', :git => "https://git.earthdata.nasa.gov/scm/cmrarc/omniauth-urs.git", tag: "release/v1.2.0"
gem 'omniauth-rails_csrf_protection'
# gem 'omniauth-urs', :git => "https://git.earthdata.nasa.gov/scm/cmrarc/omniauth-urs.git", path: "/Users/cgokey/src/rails/ruby2.7.2/omniauth-urs"

gem 'figaro'
gem 'rails-controller-testing'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'rdoc'
  gem 'rubyzip', '1.3.0'
  gem 'rails-erd'
end
