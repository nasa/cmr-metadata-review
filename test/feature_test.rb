class FeatureTest < Capybara::Rails::TestCase
  before do
    DatabaseCleaner.start
  end
  after do
    DatabaseCleaner.clean
  end
end