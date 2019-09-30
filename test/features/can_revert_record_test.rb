require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class CanRevertRecordTest < Capybara::Rails::TestCase
  include Helpers::UserHelpers

  describe 'Reverting Collections' do
    before do
      OmniAuth.config.test_mode = true
      mock_login(role: 'admin')

      stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC")
        .with(
          headers: { 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept' => '*/*', 'User-Agent' => 'Ruby' }
        )
        .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>0</hits><took>32</took></results>', headers: {})
    end

    it 'can revert a record, mimics workflow in issue CMRARC-484' do
      visit '/home'

      within '#in_daac_review' do
        check 'record_id_'
        within '.navigate-buttons' do
          click_on 'See Review Detail'
        end
      end
      click_on 'Curation Home'

      within '#in_daac_review' do
        check 'record_id_'
        within '.navigate-buttons' do
          click_on 'Revert'
        end
        page.driver.browser.switch_to.alert.accept
      end

      assert page.has_content? 'The record C1000000020-LANCEAMSR2 was successfully updated.'
    end
  end
end

