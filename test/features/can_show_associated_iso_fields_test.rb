require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class UpdateReviewCommentTest < Capybara::Rails::TestCase
  include Helpers::UserHelpers
  include Helpers::ReviewsHelper

  before do
    OmniAuth.config.test_mode = true
    mock_login(role: 'arc_curator')
    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC")
        .with(
            headers: { 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept' => '*/*', 'User-Agent' => 'Ruby' }
        )
        .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>0</hits><took>32</took></results>', headers: {})
  end

  describe 'Show ingested iso record.' do
    it 'Navigate to show iso field mapping' do
      visit '/home'
      within '#in_arc_review' do
        all('#record_id_')[1].click  # Selects the first checkbox in "in arc review records"
        find('div > div.navigate-buttons > input.selectButton').click # Clicks the See Review Details button
      end
      within '#collection_revision_1' do
        click_on "See Collection Review Details"
      end
      click_on 'Collection Info'
      assert has_content? "gco:CharacterString= gov.nasa.esdis.umm.shortname"
      assert has_content? "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:defaultLocale/lan:PT_Locale/lan:language/lan:LanguageCode"
    end
  end
end