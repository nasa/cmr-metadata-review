require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class CanShowCollectionsTest < SystemTestCase
  include Helpers::UserHelpers
  include Helpers::CollectionsHelper
  include Helpers::HomeHelper

  # describe 'when the user is an Admin' do
  setup do
      OmniAuth.config.test_mode = true
      mock_login(role: 'admin')

      stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC")
        .with(
          headers: { 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept' => '*/*' }
        )
        .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>0</hits><took>32</took></results>', headers: {})

    end

  test 'cannot see link for editing mmt' do
      visit '/home'

      within '#in_arc_review' do
        # checks the check box next to the first collection record in the tables
        find(:css, "#record_id_[value='1']").set(true)

        within '.navigate-buttons' do
          click_on 'See Review Detail'
        end
      end

      # Tests to see if the edit collection in mmt link is there.
      page.wont_have_link('EDIT COLLECTION IN MMT')
    end

  test 'can see 3 revisions when select record from in_daac_review section' do
      visit '/home'

      within '#in_daac_review' do
        # checks the check box next to the first collection record in the table
        all('#record_id_')[1].click
        within '.navigate-buttons' do
          click_on 'See Review Detail'
        end
      end
      # There should be 5 revisions associated with the collection record
      page.must_have_button('See Collection Review Details', minimum: 5)
    end
  # end
end
