class FeatureTest < Capybara::Rails::TestCase
  after do
    DatabaseCleaner.clean
  end
end