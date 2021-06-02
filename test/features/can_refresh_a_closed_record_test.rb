require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class CanRefreshAClosedRecordTest < Capybara::Rails::TestCase
  include Helpers::UserHelpers
  include Helpers::ReviewsHelper
  include Helpers::HomeHelper
  include Helpers::CollectionsHelper

  before do
    OmniAuth.config.test_mode = true
    mock_login(role: 'admin')

    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC")
        .with(
            headers: {'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept' => '*/*', 'User-Agent' => 'Ruby'}
        )
        .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>0</hits><took>32</took></results>', headers: {})

    stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/collections.xml?concept_id%5B%5D=metric1-PODAAC")
        .with(
            headers: {
                'Accept' => '*/*',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'User-Agent' => 'Ruby'}
        )
        .to_return(status: 200, body: "<results>
            <hits>1</hits>
            <took>8</took>
            <references>
            <reference>
            <name>
            Waveglider data for the SPURS-1 N. Atlantic field campaign
            </name>
            <id>metric1-PODAAC</id>
            <location>
            https://cmr.earthdata.nasa.gov:443/search/concepts/metric1-PODAAC/4
            </location>
            <revision-id>4</revision-id>
            </reference>
            </references>
            </results>", headers: {})

    stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/collections.atom?concept_id=metric1-PODAAC")
        .with(
            headers: {
                'Accept' => '*/*',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'User-Agent' => 'Ruby'}
        )
        .to_return(status: 200, body: get_stub('collections_atom_metric1-PODAAC.xml'), headers: {})

    stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/collections.umm_json?concept_id=metric1-PODAAC")
        .with(
            headers: {
                'Accept' => '*/*',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'User-Agent' => 'Ruby'}
        )
        .to_return(status: 200, body: get_stub('collections.umm_json_metric1-PODAAC.json'), headers: {})
  end

  describe "GET #refresh" do
    it "refreshes a record and informs user collection has already been ingested." do
      visit '/home'
      find("#closed_records_button").click
      within '#closed' do
        all('#record_id_')[0].click
      end
      sleep 1
      screenshot_and_open_image
      click_on 'Refresh'
      page.must_have_content(`Latest revision for Collection has already been ingested`)
    end

    it "refreshes a record and informs user a new revision has been ingested." do
      visit '/home'
      find("#closed_records_button").click
      within '#closed' do
        all('#record_id_')[0].click
      end
      sleep 1
      screenshot_and_open_image
      click_on 'Refresh'
      page.must_have_content(`Latest revision for Collection has been ingested`)
    end
  end
end