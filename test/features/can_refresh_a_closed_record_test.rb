require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class CanRefreshAClosedRecordTest < SystemTestCase
  include Helpers::UserHelpers
  include Helpers::ReviewsHelper
  include Helpers::HomeHelper
  include Helpers::CollectionsHelper

  before do
    OmniAuth.config.test_mode = true
    mock_login(role: 'admin')
  end

  describe "GET #refresh" do
    it "refreshes a record and informs user collection has already been ingested." do
      # https://cmr.earthdata.nasa.gov/search/concepts/C1652975935-PODAAC.native
      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/collections.xml?concept_id%5B%5D=metric1-PODAAC")
      .with(
          headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent' => 'Ruby'}
      )
      .to_return(status: 200, body: get_stub('collections_xml_metric1-PODAAC_revision4.xml'), headers: {'content-type': 'application/xml; charset=utf-8'})

      visit '/home'
      find("#closed_records_button").click
      within '#closed' do
        all('#record_id_')[0].click
      end
      click_on 'Refresh'
      page.must_have_content('Latest revision for Collection metric1-PODAAC has already been ingested')
    end

    it "refreshes a record and informs user a new revision has been ingested." do
      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/collections.xml?concept_id%5B%5D=metric1-PODAAC")
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent' => 'Ruby'}
          )
          .to_return(status: 200, body: get_stub('collections_xml_metric1-PODAAC_revision5.xml'), headers: {'content-type': 'application/xml; charset=utf-8'})

      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/collections.atom?concept_id=metric1-PODAAC")
          .with(
              headers: {
                  'Accept' => '*/*',
                  'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                  'User-Agent' => 'Ruby'}
          )
          .to_return(status: 200, body: get_stub('collections_atom_metric1-PODAAC.xml'), headers: {'content-type': 'application/atom+xml; charset=utf-8'})

      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/collections.umm_json?concept_id=metric1-PODAAC")
          .with(
              headers: {
                  'Accept' => '*/*',
                  'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                  'User-Agent' => 'Ruby'}
          )
          .to_return(status: 200, body: get_stub('collections.umm_json_metric1-PODAAC.json'), headers: {'content-type': 'application/vnd.nasa.cmr.umm_results+json;version=1.16.3; charset=utf-8'})

      visit '/home'
      find("#closed_records_button").click
      within '#closed' do
        all('#record_id_')[0].click
      end
      click_on 'Refresh'
      page.must_have_content('Latest revision for Collection metric1-PODAAC has been ingested')
    end
  end
end