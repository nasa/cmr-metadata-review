require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each {|f| require f}

class AssociatingGranulesTest < ActionDispatch::SystemTestCase
  include Helpers::UserHelpers
  include Helpers::HomeHelper

  before do
    OmniAuth.config.test_mode = true
    mock_login(role: 'arc_curator')

    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC")
      .with(
        headers: {'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept' => '*/*'}
      )
      .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>0</hits><took>32</took></results>', headers: {})
  end

  describe 'Granule Assocations' do
    describe 'associate granules to collections' do
      it 'can assign granule to collection' do
        visit '/home'

        within '#open' do
          all('#record_id_')[0].click  # Selects the checkbox in "in daac review"
          find('div > div.navigate-buttons > input.selectButton').click # Clicks the See Review Details button
        end
        within '#form-9' do
          first('#associated_granule_value').find("option[value='Undefined']").click # other tests are not cleaning up db, so reset it back manually
          first('#associated_granule_value').find("option[value='5']").click # Click in select box for what granule to associate
        end
        page.must_have_content('Granule G309210-GHRC/1 has been successfully associated to this collection revision 9.')
      end


      it 'can assign "no granule review" to a collection' do
        visit '/home'

        within '#open' do
          all('#record_id_')[0].click  # Selects the checkbox in "in daac review"
          find('div > div.navigate-buttons > input.selectButton').click # Clicks the See Review Details button
        end
        within '#form-9' do
          first('#associated_granule_value').find("option[value='Undefined']").click # other tests are not cleaning up db, so reset it back manually
          first('#associated_granule_value').find("option[value='No Granule Review']").click # Clicks No Granule Review Option
        end
        page.must_have_content("associated granule will be marked as 'No Granule Review'")
      end

    end

    describe 'associated granule reports' do
      it 'associated granule shows up in reports' do
        mock_login(role: 'admin')
        visit '/home'

        within '#in_daac_review' do
          all('#record_id_')[0].click  # Selects the checkbox in "in daac review"
          find('div > div.navigate-buttons > input.selectButton').click # Clicks the See Review Details button
        end

        within '#form-9' do
          first('#associated_granule_value').find("option[value='Undefined']").click # other tests are not cleaning up db, so reset it back manually
          first('#associated_granule_value').find("option[value='5']").click # Click in select box for what granule to associate
        end
        page.must_have_content('Granule G309210-GHRC/1 has been successfully associated to this collection revision 9.')

        visit '/home' # go back to home page
        within '#in_daac_review' do
          all('#record_id_')[0].click # select the record again in "in daac review"
          find('div > div.navigate-buttons > input.reportButton').click # click the report button
        end
        page.must_have_content('C1000000020-LANCEAMSR2-9') # verify the collection record is in the report
        page.must_have_content('G309210-GHRC-1') # verify the granule association is in the report
        page.must_have_content('RECORD METRICS') # verify it has report metrics
        page.assert_selector('.checked_num', count: 2) # of elements reviewed appears twice.
      end
    end
  end

  # Note had to move this test of the main tests as we were not getting proper database cleanup after each test
  describe 'mark as undefined' do
    it 'can mark a granule back to undefined' do
      visit '/home'

      within '#open' do
        all('#record_id_')[0].click  # Selects the checkbox in "in daac review"
        find('div > div.navigate-buttons > input.selectButton').click # Clicks the See Review Details button
      end
      within '#form-9' do
        first('#associated_granule_value').find("option[value='Undefined']").click # other tests are not cleaning up db, so reset it back manually
        first('#associated_granule_value').find("option[value='5']").click # Click in select box for what granule to associate
      end
      page.must_have_content('Granule G309210-GHRC/1 has been successfully associated to this collection revision 9.')
      within '#form-9' do
        first('#associated_granule_value').find("option[value='Undefined']").click # select undefined to set it back
      end
      page.must_have_content("associated granule will be marked as 'Undefined'")
    end
  end

  describe 'perform checks associating granule to collection' do
    it 'checks has reviewers, all colors, and no second opinions' do
      mock_login(role: 'admin')
      visit '/home'

      see_collection_review_details("#in_daac_review", 12)

      within '#form-9' do
        first('#associated_granule_value').find("option[value='Undefined']").click # other tests are not cleaning up db, so reset it back manually
        first('#associated_granule_value').find("option[value='16']").click # Click in select box for what granule to associate
      end

      page.must_have_content('The associated granule needs two completed reviews')
      page.must_have_content('Not all columns in the associated granule have been flagged with a color!')
      page.must_have_content('Some columns in the associated granule still need a second opinion review.')
    end
  end
end