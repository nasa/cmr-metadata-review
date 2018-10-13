source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.10'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.3.12', group: [:test]
# use pg for local and prod development
gem 'pg', '~> 0.17.1', group: [:test, :development, :production]


# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'httparty', '~> 0.14.0'
gem 'aasm', '~> 4.12.0'

gem 'rubyXL'
gem 'ruby-progressbar'

group :test do
  gem 'minitest-spec-rails'
  gem 'webmock'
  gem 'mocha'
  gem 'minitest-reporters', '1.3.0'
  gem 'minitest-rails-capybara'
end

group :development, :test do
  gem 'pry-rails'
  gem 'pry-byebug'
end

#coverage map for testing
gem 'simplecov', :require => false, :group => :test

#using puma server instead of webBrick
gem 'puma', '~> 3.6.2'
#base authentication gem
gem 'devise'
#setting user permissions for pages
gem 'cancan', '~> 1.6.10'

#js runtime
gem 'execjs', '~> 2.7.0'
#communication with aws S3 & other utils
gem 'aws-sdk', '~> 2.2.37'
#store env vars in the .env file
gem 'dotenv-rails', '~> 2.1.1'

# Should use 5.0.13 but compatibility issues with SIT version of RH, has older GCC.    Eventualaly when they upgrade RH, we can move back to the latest
gem 'font-awesome-sass', '5.0.9'
gem 'font-awesome-rails'
gem 'activerecord-session_store'
gem 'whenever', require: false
gem 'oauth2'
gem 'omniauth-oauth2'

gem 'omniauth-urs', :git => "https://git.earthdata.nasa.gov/scm/cmrarc/omniauth-urs.git", branch: "develop"

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'rdoc'
  gem 'rubyzip', '1.2.2'
end
