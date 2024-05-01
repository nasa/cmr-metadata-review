require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class CanShowCollectionsDaacTest < SystemTestCase
  include Helpers::UserHelpers
  include Helpers::CollectionsHelper
  include Helpers::HomeHelper

  setup do
    OmniAuth.config.test_mode = true
    mock_login(role: 'daac_curator', uid: 5)

    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC")
      .with(
        headers: { 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept' => '*/*' }
      )
      .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>0</hits><took>32</took></results>', headers: {})
  end

  test 'can see link for editing mmt' do
    visit '/home'

    within '#in_daac_review' do
      # checks the check box next to the first collection record in the table
      all('#record_id_')[0].click

      within '.navigate-buttons' do
        click_on 'See Review Detail'
      end
    end

    # Tests to see if the edit collection in mmt link is there.
    page.must_have_link('EDIT COLLECTION IN MMT')
    # There should be only one granule revision with state 'in_daac_review' shown
    page.must_have_button('See Granule Review Details', maximum: 1)
  end

  test 'can see only one revision which is in_daac_review' do
    visit '/home'
    within '#in_daac_review' do
      # checks the check box next to the first collection record in the table
      all('#record_id_')[1].click

      within '.navigate-buttons' do
        click_on 'See Review Detail'
      end
    end

    # Tests to see if the edit collection in mmt link is there.
    page.must_have_link('EDIT COLLECTION IN MMT')
    # There should be only one revision with state 'in_daac_review' shown
    page.must_have_button('See Collection Review Details', maximum: 1)
  end
end