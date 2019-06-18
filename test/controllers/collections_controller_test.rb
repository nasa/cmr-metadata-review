require 'test_helper'
Dir[Rails.root.join("test/**/*.rb")].each {|f| require f}

class CollectionsControllerTest < ActionController::TestCase
  include OmniauthMacros

  let(:user) { User.find_by_email("abaker@element84.com") }

  setup do
    @cmr_base_url = Cmr.get_cmr_base_url
  end

  describe "GET #show" do
    it "loads the correct collection on show" do
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      #stubbing all requests for raw_data
      stub_request(:get, "#{@cmr_base_url}/search/collections.echo10?concept_id=C1000000020-LANCEAMSR2").with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => get_stub("search_collection_C1000000020-LANCEAMSR2.xml"), :headers => {"date"=>["Tue, 21 Feb 2017 16:02:46 GMT"], "content-type"=>["application/echo10+xml; charset=utf-8"], "access-control-expose-headers"=>["CMR-Hits, CMR-Request-Id"], "access-control-allow-origin"=>["*"], "cmr-hits"=>["10554"], "cmr-took"=>["40"], "cmr-request-id"=>["5b0c8426-3a23-4025-a4d3-6d1c9024153a"], "vary"=>["Accept-Encoding, User-Agent"], "connection"=>["close"], "server"=>["Jetty(9.2.z-SNAPSHOT)"]})

      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/granules.echo10?concept_id=G309210-GHRC").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: get_stub('search_granules_G309210-GHRC.xml'), headers: {})

      get :show, id: 1, record_id: 1
      collection_records = assigns(:collection_records)
      assert_equal(3, collection_records.length)
    end

    it "contains a link to mmt collection record" do
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      #stubbing all requests for raw_data
      stub_request(:get, "#{@cmr_base_url}/search/collections.echo10?concept_id=C1000000020-LANCEAMSR2").with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => get_stub('search_granules_by_collection_C1000000020-LANCEAMSR2.xml'))

      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/granules.echo10?concept_id=G309210-GHRC").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200,
                  body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>0</hits><took>29</took></results>',
                  headers: {})

      get :show, id: 1, record_id: 1
      assert_select '.edit_collection_in_mmt_link', count:1
    end

    it "redirects when no concept id is provided" do
      #redirects no record_id
      get :show, id: 1
      assert_equal(response.code, "302")
    end

    it "redirects when no collection is found" do
      #redirects no collection found
      get :show, id: 1, record_id: "xyz"
      assert_equal(response.code, "302")
    end

  it "detects if a granule is no longer in cmr" do
    sign_in(user)
    stub_urs_access(user.uid, user.access_token, user.refresh_token)

    #stubbing all requests for raw_data
    stub_request(:get, "#{@cmr_base_url}/search/collections.echo10?concept_id=C1000000020-LANCEAMSR2").with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => get_stub('search_granules_by_collection_C1000000020-LANCEAMSR2.xml'))

    stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/granules.echo10?concept_id=G309210-GHRC").
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
        }).
      to_return(status: 200,
                body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>0</hits><took>29</took></results>',
                headers: {})

    # The fixtures indicate collection C1000000020-LANCEAMSR2 has 2 granule revisions for G30920-GHRC, we are
    # stubbing the request so when GET show action is called and checks to see if these revisions are still there,
    # it will return 0 hits.
    get :show, id: 1, record_id: 1
    assert_select "span[class='indicator_for_granule_deleted_in_cmr']", count:2,
                  :text => '[Granule Not Found in CMR]'
  end

  it "detects if a new granule revision is available" do
    sign_in(user)
    stub_urs_access(user.uid, user.access_token, user.refresh_token)

    stub_request(:get, "#{@cmr_base_url}/search/collections.echo10?concept_id=C1000000020-LANCEAMSR2").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => get_stub('search_granules_by_collection_C1000000020-LANCEAMSR2.xml'))

    stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/granules.echo10?concept_id=G309210-GHRC").
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: get_stub('search_granules_G309210-GHRC.xml'), headers: {})

    # As part of the fixtures, this collection has 2 existing granule revisions #1 and #6
    # The stubbed request provides a new revision that can be pulled, #15, so the test
    # checks if the #ingest_pull_latest id is in the HTML exactly twice indicating
    # there is a new revision to pull.
    get :show, id: 1, record_id: 1
    assert_select '.import_new_revision', count:2
  end
end



describe "POST #create" do
    it "downloads and saves a new record" do
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      stub_request(:get, Regexp.new("#{Regexp.escape(@cmr_base_url)}\\/search\\/collections\\.(echo10|native)\\?concept_id\\=C222702\\-GHRC")).with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => get_stub("search_collection_C222702-GHRC.xml"), :headers => {"date"=>["Tue, 21 Feb 2017 15:50:04 GMT"], "content-type"=>["application/echo10+xml; charset=utf-8"], "access-control-expose-headers"=>["CMR-Hits, CMR-Request-Id"], "access-control-allow-origin"=>["*"], "cmr-hits"=>["1"], "cmr-took"=>["2974"], "cmr-request-id"=>["bb005bac-18ce-4b6a-b69f-3f29f820ced5"], "vary"=>["Accept-Encoding, User-Agent"], "connection"=>["close"], "server"=>["Jetty(9.2.z-SNAPSHOT)"]})
      #stubbing the new format check
      stub_request(:get, "#{@cmr_base_url}/search/collections.atom?concept_id=C222702-GHRC").with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><feed xmlns:os=\"http://a9.com/-/spec/opensearch/1.1/\" xmlns:georss=\"http://www.georss.org/georss/10\" xmlns=\"http://www.w3.org/2005/Atom\" xmlns:dc=\"http://purl.org/dc/terms/\" xmlns:echo=\"http://www.echo.nasa.gov/esip\" xmlns:esipdiscovery=\"http://commons.esipfed.org/ns/discovery/1.2/\" xmlns:gml=\"http://www.opengis.net/gml\" esipdiscovery:version=\"1.2\" xmlns:time=\"http://a9.com/-/opensearch/extensions/time/1.0/\"><entry><echo:originalFormat>ECHO10</echo:originalFormat></entry></feed>", :headers => {"date"=>["Fri, 17 Mar 2017 20:00:54 GMT"], "content-type"=>["application/echo10+xml; charset=utf-8"], "access-control-expose-headers"=>["CMR-Hits, CMR-Request-Id"], "access-control-allow-origin"=>["*"], "cmr-hits"=>["1"], "cmr-took"=>["107"], "cmr-request-id"=>["308d3b81-b229-4593-a05e-c61a741d45be"], "vary"=>["Accept-Encoding, User-Agent"], "connection"=>["close"], "server"=>["Jetty(9.2.z-SNAPSHOT)"], "strict-transport-security"=>["max-age=31536000"]})

      #Since a granule is chosen at random, a full mock can not be used.
      #in this instance, we return a set collection of results for any call using this concept id and granule keyword.
      stub_request(:get, /.*granules.*C222702-GHRC.*/).with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => get_stub("search_granules_G309203-GHRC.xml"), :headers => {"date"=>["Tue, 21 Feb 2017 16:02:46 GMT"], "content-type"=>["application/echo10+xml; charset=utf-8"], "access-control-expose-headers"=>["CMR-Hits, CMR-Request-Id"], "access-control-allow-origin"=>["*"], "cmr-hits"=>["10554"], "cmr-took"=>["40"], "cmr-request-id"=>["5b0c8426-3a23-4025-a4d3-6d1c9024153a"], "vary"=>["Accept-Encoding, User-Agent"], "connection"=>["close"], "server"=>["Jetty(9.2.z-SNAPSHOT)"]})

      #stubbing the granule raw look up
      stub_request(:get, /.*granules.echo10\?concept_id=G.*/).with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => get_stub("search_granules_G226250-GHRC.xml"), :headers => {"date"=>["Tue, 14 Mar 2017 19:36:02 GMT"], "content-type"=>["application/echo10+xml; charset=utf-8"], "access-control-expose-headers"=>["CMR-Hits, CMR-Request-Id"], "access-control-allow-origin"=>["*"], "cmr-hits"=>["1"], "cmr-took"=>["26"], "cmr-request-id"=>["46ad6de7-598a-463e-99e0-2a22ddf651da"], "vary"=>["Accept-Encoding, User-Agent"], "connection"=>["close"], "server"=>["Jetty(9.2.z-SNAPSHOT)"], "strict-transport-security"=>["max-age=31536000"]})

      #Making sure record does not exist before ingest
      assert_equal(0, (Collection.where concept_id: "C222702-GHRC").length)

      post :create, concept_id: "C222702-GHRC", revision_id: "32", granulesCount: 1

      #redirects after creation
      assert_equal("302", response.code)

      #collection with rawJSON saved in system
      assert_equal(1, (Collection.where concept_id: "C222702-GHRC").length)
      assert_equal("daylightn", (Collection.where concept_id: "C222702-GHRC").first.records.first.values["ShortName"])

      record = (Collection.where concept_id: "C222702-GHRC").first.records.first
      #script ran on new collection
      refute(record.binary_script_values["InsertTime"])

      #ingest for collection logged
      assert_equal("abaker@element84.com", record.ingest.user.email)

      #saves 1 associated granule
      assert_equal(1, (Collection.where concept_id: "C222702-GHRC").first.granules.length)
      #needs to match regex since the granule that is taken from the list is random each time
      assert_equal(0, (Collection.where concept_id: "C222702-GHRC").first.granules.first.records.first.values["GranuleUR"] =~ /Ndaily/)

      granule_record = (Collection.where concept_id: "C222702-GHRC").first.granules.first.records.first
      #ingest for granule logged
      assert_equal("abaker@element84.com", granule_record.ingest.user.email)
    end
  end
end
