require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class CanSearchCollectionTest < SystemTestCase
  include Helpers::UserHelpers
  include Helpers::ReviewsHelper
  include Helpers::CollectionsHelper
  include Helpers::HomeHelper

  before do
    OmniAuth.config.test_mode = true
    mock_login(role: 'admin')
    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/collections.echo10?keyword=**&page_num=1&page_size=10&provider=LANCEAMSR2").
        with(
            headers: {
                'Accept'=>'*/*',
                'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'User-Agent'=>'Ruby'
            }).
        to_return(status: 200, body: get_stub('search_collection_provider_ghrc.xml'), headers: {})
    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/collections.echo10?concept_id=C1996546695-GHRC_DAAC").
        with(
            headers: {
                'Accept'=>'*/*',
                'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'User-Agent'=>'Ruby'
            }).
        to_return(status: 200, body: get_stub('search_collection_C1996546695-GHRC_DAAC.xml'), headers: {})
    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=C1996546695-GHRC_DAAC&page_num=1&page_size=10").
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><results><hits>0</hits><took>8</took></results>", headers: {})
    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/collections.atom?concept_id=C1996546695-GHRC_DAAC").
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: get_stub("search_collection_C1996546695-GHRC_DAAC.atom"), headers: {})
    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/concepts/C1996546695-GHRC_DAAC.echo10").
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: get_stub("C1996546695-GHRC_DAAC_echo10.xml"), headers: {})
    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.umm_json?collection_concept_id=C1996546695-GHRC_DAAC&page_size=10&page_num=1").
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: '{"hits" : 0, "took" : 105, "items" : []}', headers: {})

  end
  describe 'search cmr collection' do

    # This test fails due to a bug in pyQuARC:
    it 'search collection by GHRC provider' do
      visit '/home'
      within '#provider' do
        find("#provider > option:nth-child(6)").click
      end
      find("#search_button").click
      assert has_content?('C1996543397-GHRC_DAAC')
      assert has_content?('C1996546695-GHRC_DAAC')
      assert has_content?('C1979115640-GHRC_DAAC')
      assert has_content?('C1979116062-GHRC_DAAC')
      find('#search3').click
      click_on 'Select Collection'
      Quarc.stub_any_instance(:validate, {}) do
        click_on 'Ingest Collection Without Granule'
      end
      assert has_content?('C1996546695-GHRC_DAAC')
    end
  end
end
