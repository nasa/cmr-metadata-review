require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each {|f| require f}

class AssociatingGranulesTest < FeatureTest
  include Helpers::UserHelpers

  describe 'Granule Assocations' do
    before do
      OmniAuth.config.test_mode = true
      mock_login(role: 'arc_curator')

      stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC")
        .with(
          headers: {'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept' => '*/*', 'User-Agent' => 'Ruby'}
        )
        .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>0</hits><took>32</took></results>', headers: {})
    end

    describe 'associate granules to collections' do
      it 'can assign granule to collection' do
        visit '/home'
        wait_for_jQuery(5)

        all('#record_id_')[0].click
        find('#open > div > div.navigate_buttons > input').click
        first("#associated_granule_value").find("option[value='5']").click
        page.must_have_content('Granule G309210-GHRC/1 has been successfully associated to this collection revision 9.')
      end

      it 'can assign "no granule review" to a collection' do
        visit '/home'
        wait_for_jQuery(5)

        all('#record_id_')[0].click
        find('#open > div > div.navigate_buttons > input').click
        first("#associated_granule_value").find("option[value='No Granule Review']").click
        page.must_have_content("associated granule will be marked as 'No Granule Review'")
      end

      it 'can mark a granule back to undefined' do
        visit '/home'
        wait_for_jQuery(5)

        all('#record_id_')[0].click
        find('#open > div > div.navigate_buttons > input').click
        first("#associated_granule_value").find("option[value='5']").click
        page.must_have_content('Granule G309210-GHRC/1 has been successfully associated to this collection revision 9.')
        first("#associated_granule_value").find("option[value='Undefined']").click
        page.must_have_content("associated granule will be marked as 'Undefined'")
      end
    end

    describe 'associated granule reports' do
      it 'associated granule shows up in reports' do
        mock_login(role: 'admin')
        visit '/home'
        wait_for_jQuery(5)

        all('#record_id_')[1].click
        find('#in_daac_review > div > div.navigate_buttons > input.selectButton').click
        first("#associated_granule_value").find("option[value='5']").click
        page.must_have_content('Granule G309210-GHRC/1 has been successfully associated to this collection revision 9.')
        visit '/home'
        all('#record_id_')[1].click
        find('#in_daac_review > div > div.navigate_buttons > input.reportButton').click
        page.must_have_content('C1000000020-LANCEAMSR2-9')
        page.must_have_content('G309210-GHRC-1')
        page.must_have_content('RECORD METRICS')
        page.assert_selector('.checked_num', count: 2) # #  of elements reviewed.
      end
    end
  end
end


