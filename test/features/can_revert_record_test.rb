require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class CanRevertRecordTest < SystemTestCase
  include Helpers::UserHelpers

  describe 'Reverting Collections' do
    before do
      OmniAuth.config.test_mode = true
      mock_login(role: 'admin')

      stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC")
        .with(
          headers: { 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept' => '*/*' }
        )
        .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>0</hits><took>32</took></results>', headers: {})
    end

    # Note although the test below mimics the workflow in CMRARC-494, we could not get capybara to replicate it,
    # but still figured it was worth including as an additional test in any case.
    it 'can revert a record, mimics workflow in issue CMRARC-484' do
      visit '/home'

      within '#in_daac_review' do
        all('#record_id_')[0].click
        within '.navigate-buttons' do
          click_on 'See Review Detail'
        end
      end
      click_on 'Curation Home'

      within '#in_daac_review' do
        all('#record_id_')[0].click
        within '.navigate-buttons' do
          click_on 'Revert'
        end
        page.driver.browser.switch_to.alert.accept
      end

      assert page.has_content? 'The record C1000000020-LANCEAMSR2 was successfully updated.'
    end
  end
end


