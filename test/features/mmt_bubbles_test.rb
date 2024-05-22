require 'test_helper'
require 'capybara/rails'
require 'capybara/minitest'
Dir[Rails.root.join('test/**/*.rb')].each {|f| require f}

class MmtBubblesTest < SystemTestCase
  include Helpers::UserHelpers

  before do
    OmniAuth.config.test_mode = true
    mock_login(role: 'arc_curator')

    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC")
      .with(
        headers: {'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept' => '*/*'}
      )
      .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>0</hits><took>32</took></results>', headers: {})
  end

  describe 'ingesting a umm-c collection record' do
    # this test will mock a user click on a bubble and then navigate to the correct
    # sub-section it indicates in the review table.
    it 'shows mmt section bubbles' do
      visit '/home'

      within '#in_arc_review' do
        all('#record_id_')[2].click  # Selects the third checkbox in "in arc review records" which is a umm-c record
        find('div > div.navigate-buttons > input.selectButton').click # Clicks the See Review Details button
      end
      within '#collection_revision_1' do
        click_on "See Collection Review Details"
      end
      assert_selector("[data-testid='records--show__Data Identification']")
      find("[data-testid='records--show__Data Identification']").click
      within "#review_table" do
        assert_selector('#column_Quality')
      end
    end
  end
end
