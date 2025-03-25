require 'test_helper'
Dir[Rails.root.join("test/**/*.rb")].each { |f| require f }

class CollectionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include OmniauthMacros

  let(:user) { User.find_by_email("abaker@element84.com") }

  setup do
    @cmr_base_url = Cmr.get_cmr_base_url
  end

  describe 'GET #search' do
    it 'returns MODIS results' do
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      stub_request(:get, "#{@cmr_base_url}/search/collections.echo10?keyword=*modis*&page_num=1&page_size=10&provider=ORNL_CLOUD")
        .with(headers: default_headers)
        .to_return(status: 200, body: get_stub('modis-search.xml'))

      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/collections.echo10?keyword=*modis*&page_num=1&page_size=10&provider=GESDISCCLD")
        .with(headers: default_headers)
        .to_return(status: 200, body: get_stub('modis-search.xml'))

      get '/collections_search', params: { provider: 'DAAC: ANY', free_text: 'modis', curr_page: 1 }
      
      assert_equal 113, assigns(:collection_count)
      assert_equal 'C1200019523-OB_DAAC', assigns(:search_iterator)[0]['concept_id']
    end
  end

  describe "GET #show" do
    it "loads the correct collection on show" do
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)
      setup_show_stubs

      get '/collections/1', params: { record_id: 1 }
      
      assert_equal 6, assigns(:collection_records).length
    end

    it "redirects when no concept id is provided" do
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      get '/collections/1', params: {}
      assert_redirected_to root_path
    end

    it "redirects when no collection is found" do
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      get '/collections/1', params: { record_id: "xyz" }
      assert_redirected_to root_path
    end

    it "detects if a granule is no longer in CMR" do
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)
      setup_granule_not_found_stubs

      get '/collections/1', params: { record_id: 1 }
      
      assert_select ".indicator_for_granule_deleted_in_cmr", count: 5, text: '[Granule Not Found in CMR]'
    end

    it "detects if a new granule revision is available" do
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)
      setup_granule_revision_stubs

      get '/collections/1', params: { record_id: 1 }
      
      assert_select '.import_new_revision', count: 5
    end
  end

  describe "POST #create" do
    it "downloads and saves a new record" do
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)
      setup_create_stubs

      assert_difference 'Collection.where(concept_id: "C222702-GHRC").count', 1 do
        Quarc.stub_any_instance(:validate, {}) do
          post collections_url, params: { concept_id: "C222702-GHRC", revision_id: "32", granulesCount: 1 }
        end
      end

      assert_redirected_to collection_path(assigns(:collection))
      assert_collection_and_granule_saved_correctly("C222702-GHRC")
    end

    it "downloads and saves a new ISO record as UMM-JSON" do
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)
      setup_iso_record_stubs

      assert_difference 'Collection.where(concept_id: "C1599780765-NSIDC_ECS").count', 1 do
        Quarc.stub_any_instance(:validate, {}) do
          post collections_url, params: { concept_id: "C1599780765-NSIDC_ECS", revision_id: "77", granuleCounts: 1 }
        end
      end

      assert_redirected_to collection_path(assigns(:collection))
      assert_iso_record_saved_correctly("C1599780765-NSIDC_ECS")
    end
  end

  private

  def default_headers
    {
      'Accept' => '*/*',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent' => 'Ruby'
    }
  end

  def setup_show_stubs
    stub_request(:get, "#{@cmr_base_url}/search/collections.echo10?concept_id=C1000000020-LANCEAMSR2")
      .with(headers: default_headers)
      .to_return(status: 200, body: get_stub("search_collection_C1000000020-LANCEAMSR2.xml"))

    stub_request(:get, "#{@cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC")
      .with(headers: default_headers)
      .to_return(status: 200, body: get_stub('search_granules_G309210-GHRC.xml'))

    stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/granules.umm_json?concept_id=G309210-GHRC")
      .with(headers: default_headers)
      .to_return(status: 200, body: get_stub('search_granules_G309210-GHRC.json'))
  end

  def setup_granule_not_found_stubs
    stub_request(:get, "#{@cmr_base_url}/search/granules.umm_json?concept_id=G309210-GHRC")
      .with(headers: default_headers)
      .to_return(status: 200, body: '{"hits" : 0,"took" : 105,"items" : []}')

    stub_request(:get, "#{@cmr_base_url}/search/collections.echo10?concept_id=C1000000020-LANCEAMSR2")
      .with(headers: default_headers)
      .to_return(status: 200, body: get_stub('search_granules_by_collection_C1000000020-LANCEAMSR2.xml'))

    stub_request(:get, "#{@cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC")
      .with(headers: default_headers)
      .to_return(status: 200, body: '<results><hits>0</hits><took>29</took></results>')
  end

  def setup_granule_revision_stubs
    stub_request(:get, "#{@cmr_base_url}/search/collections.echo10?concept_id=C1000000020-LANCEAMSR2")
      .with(headers: default_headers)
      .to_return(status: 200, body: get_stub('search_granules_by_collection_C1000000020-LANCEAMSR2.xml'))

    stub_request(:get, "#{@cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC")
      .with(headers: default_headers)
      .to_return(status: 200, body: get_stub('search_granules_G309210-GHRC.xml'))

    stub_request(:get, "#{@cmr_base_url}/search/granules.umm_json?concept_id=G309210-GHRC")
      .with(headers: default_headers)
      .to_return(status: 200, body: get_stub('search_granules_G309210-GHRC.json'))
  end

  def setup_create_stubs
    stub_request(:get, "#{@cmr_base_url}/search/collections.echo10?concept_id=C222702-GHRC")
      .with(headers: default_headers)
      .to_return(status: 200, body: get_stub("search_collection_C222702-GHRC.xml"))

    stub_request(:get, /.*granules.echo10*C222702-GHRC.*/)
      .with(headers: default_headers)
      .to_return(status: 200, body: get_stub("search_granules_G309203-GHRC.xml"))

    stub_request(:get, /.*granules.umm_json*C222702-GHRC.*/)
      .with(headers: default_headers)
      .to_return(status: 200, body: get_stub("search_granules_G309203-GHRC.json"))
  end

  def setup_iso_record_stubs
    stub_request(:get, "#{@cmr_base_url}/search/collections.atom?concept_id=C1599780765-NSIDC_ECS")
      .with(headers: default_headers)
      .to_return(status: 200, body: get_stub("search_collection_C1599780765-NSIDC_ECS.atom"))

    stub_request(:get, "#{@cmr_base_url}/search/collections.umm_json?concept_id=C1599780765-NSIDC_ECS")
      .with(headers: default_headers)
      .to_return(status: 200, body: get_stub("search_collection_C1599780765-NSIDC_ECS.json"))

    stub_request(:get, /.*granules.echo10\?concept_id=G.*/)
      .with(headers: default_headers)
      .to_return(status: 200, body: get_stub("search_granules_C1599780765-NSIDC_ECS.xml"))

    stub_request(:get, "#{@cmr_base_url}/search/granules.umm_json?collection_concept_id=C1599780765-NSIDC_ECS&page_size=10&page_num=1")
      .with(headers: default_headers)
      .to_return(status: 200, body: get_stub('search_granules_by_collection_C1599780765-NSIDC_ECS.json'))

    stub_request(:get, "#{@cmr_base_url}/search/granules.umm_json?concept_id=G1599790933-NSIDC_ECS")
      .with(headers: default_headers)
      .to_return(status: 200, body: get_stub("search_granules_G1599790933-NSIDC_ECS.json"))
  end

  def assert_collection_and_granule_saved_correctly(concept_id)
    collection = Collection.find_by(concept_id: concept_id)
    assert collection.present?
    assert_equal "abaker@element84.com", collection.records.first.ingest.user.email
    assert_equal 1, collection.granules.count
    granule = collection.granules.first
    assert_match /Ndaily/, granule.records.first.values["GranuleUR"]
    assert_equal "abaker@element84.com", granule.records.first.ingest.user.email
  end

  def assert_iso_record_saved_correctly(concept_id)
    collection = Collection.find_by(concept_id: concept_id)
    assert collection.present?
    record = collection.records.first
    assert_equal "iso19115", record.native_format
    assert_equal "umm_json", record.format
    assert_equal "abaker@element84.com", record.ingest.user.email
    assert_equal 1, collection.granules.count
    granule = collection.granules.first
    assert_match /SC:ABLVIS0/, granule.records.first.values["GranuleUR"]
    assert_equal "abaker@element84.com", granule.records.first.ingest.user.email
  end
end
