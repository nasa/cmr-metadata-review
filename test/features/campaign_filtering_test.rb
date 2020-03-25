require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class CanShowCollectionsTest < Capybara::Rails::TestCase
  include Helpers::UserHelpers

  before do
    OmniAuth.config.test_mode = true
  end

  describe 'Campaign Filtering' do
    describe 'when the user is an Arc Curator' do
      before do
        mock_login(id: 3) # arc curator
      end
    end

    describe 'when the user is an MDQ Curator' do
      before do
        mock_login(id: 11) # mdq curator
      end
    end

    describe 'when the user is a daac Curator' do
      before do
        mock_login(id: 5) # podaac curator
      end
    end
  end
end