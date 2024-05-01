require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class CanShowCollectionsArcTest < SystemTestCase
  include Helpers::UserHelpers
  include Helpers::CollectionsHelper
  include Helpers::HomeHelper
  # describe 'when the user is an Arc Curator' do
  setup do
      OmniAuth.config.test_mode = true
      mock_login(role: 'arc_curator')

      stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC")
        .with(
          headers: { 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept' => '*/*' }
        )
        .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>0</hits><took>32</took></results>', headers: {})

    end

  test 'can show collection' do
      visit '/home'
      see_collection_review_details('#open', 20)
      see_collection_revision_details(4)
      assert has_content? 'METADATA ELEMENTS'
    end

  test 'back button works when viewing collection review' do
      visit '/home'
      see_collection_review_details('#open', 20)
      see_collection_revision_details(4)
      assert has_content? 'METADATA ELEMENTS'
      find('#nav_back_button').click
      assert has_content? 'Collection Revisions'
      assert has_content? 'Granule Rev ID'
    end

  test 'back button works when viewing granule review' do
      visit '/home'
      see_collection_review_details('#open', 20)
      see_granule_revision_details(21)
      assert has_content? 'METADATA ELEMENTS'
      find('#nav_back_button').click
      assert has_content? 'Collection Revisions'
      assert has_content? 'Granule Rev ID'
    end

  test 'cannot see link for editing mmt' do
      visit '/home'

      within '#in_arc_review' do
        # checks the check box next to the first collection record in the table
        find(:css, "#record_id_[value='1']").set(true)

        within '.navigate-buttons' do
          click_on 'See Review Detail'
        end
      end

      # Tests to see if the edit collection in mmt link is there.
      page.wont_have_link('EDIT COLLECTION IN MMT')
    end
  # end
end