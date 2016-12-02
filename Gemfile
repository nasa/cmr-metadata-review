source 'https://rubygems.org'

ruby File.read('.ruby-version').match(/\S*/).to_s
require 'open-uri'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'
# Use SCSS for stylesheets
gem 'bootstrap-sass', '~> 3.3.6'
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

gem 'httparty'

# source 'https://rails-assets.org' do
#   gem 'rails-assets-tether', '>= 1.1.0'
# end

gem 'libxml-ruby'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'mongoid', '~> 5.1.0'
gem 'bson_ext'

gem 'redis'
gem 'sidekiq', '~> 4.2.1'
gem "sidekiq-cron", "~> 0.4.0"

gem 'devise'
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'devise_token_auth', github: 'ybian/devise_token_auth', branch: 'mongoid'
gem 'unicorn'

gem 'angular_rails_csrf'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'pry'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano3-unicorn'
  gem 'capistrano-sidekiq'
  gem 'capistrano-rvm'
  gem 'rvm1-capistrano3', require: false
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

