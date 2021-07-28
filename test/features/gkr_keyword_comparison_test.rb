require 'test_helper'
require 'capybara/rails'
require 'capybara/minitest'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class GkrKeywordComparisonTest < SystemTestCase
  include Helpers::UserHelpers

  describe 'get cmr collection' do
    before do

      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/collections.umm_json?concept_id=C1200400842-GHRC").
      with(
        headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: get_stub('C1200400842-GHRC.json'), headers: {'content-type': 'application/vnd.nasa.cmr.umm_results+json;version=1.16.5; charset=utf-8'})
    end

    it 'should render page, grab parameters and retrieve appropriate collection' do
      OmniAuth.config.test_mode = true
      mock_login(role: 'admin')

      visit '/gkr_keyword_comparison'
      fill_in 'Concept ID', with: 'C1200400842-GHRC'
      fill_in 'Threshold', with: '1'
      click_on 'Submit'

      assert has_content?('The National Center for Environmental Prediction/Aviation Weather Center Infrared Global Geostationary Composite data set contains global composite images from the infrared channels of multiple weather satellites in geosynchronous orbit. These satellites include the GMS (Japan), GOES (USA), and Meteosat (Europe). These imagers span nearly the entire globe with a small gap over India. The data resolution is 14 km spatial with the data remapped into a Mercator projection. The data have not necessarily been cross calibrated between sensors.')
    end
  end
end
