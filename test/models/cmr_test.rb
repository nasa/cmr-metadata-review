require 'test_helper'
require 'stub_data'

class CmrTest < ActiveSupport::TestCase

  setup do
    @cmr_base_url = Cmr.get_cmr_base_url
  end

  describe "get_collections" do
    it "correctly gets collection from CMR api" do
      stub_request(:get, "#{@cmr_base_url}/search/collections.echo10?concept_id=C1000000020-LANCEAMSR2")
        .with(:headers => {
          'Accept'=>'*/*', 
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 
          'User-Agent'=>'Ruby'
          })
        .to_return(:status => 200, :body => get_stub("search_collections_echo10_C1000000020LANCEAMSR2.xml"), :headers => {
          "date"=>["Mon, 20 Feb 2017 19:38:25 GMT"], 
          "content-type"=>["application/echo10+xml; charset=utf-8"], 
          "access-control-expose-headers"=>["CMR-Hits, CMR-Request-Id"], 
          "access-control-allow-origin"=>["*"], "cmr-hits"=>["1"], 
          "cmr-took"=>["10"], "cmr-request-id"=>["436b50ec-c84a-4180-93fa-9c721087d65b"], 
          "vary"=>["Accept-Encoding, User-Agent"], "connection"=>["close"], 
          "server"=>["Jetty(9.2.z-SNAPSHOT)"]})
      collection = Cmr.get_collection("C1000000020-LANCEAMSR2")

      assert_equal("A2_DySno_NRT", collection["ShortName"])
      assert_equal("NRT AMSR2 DAILY L3 GLOBAL SNOW WATER EQUIVALENT EASE-GRIDS", collection["LongName"])
      assert_equal("CARTESIAN", collection["Spatial/HorizontalSpatialDomain/Geometry/CoordinateSystem"])
    end

    it "raises error when concept_id invalid" do
      stub_request(:get, "#{@cmr_base_url}/search/collections.echo10?concept_id=junk-name")
        .with(:headers => {
          'Accept'=>'*/*', 
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 
          'User-Agent'=>'Ruby'
          })
        .to_return(:status => 200, :body => '{"errors"=>{"error"=>"Concept-id [junk-name] is not valid."}}', :headers => {
          "date"=>["Mon, 20 Feb 2017 19:38:25 GMT"], 
          "content-type"=>["application/echo10+xml; charset=utf-8"], 
          "access-control-expose-headers"=>["CMR-Hits, CMR-Request-Id"], 
          "access-control-allow-origin"=>["*"], "cmr-hits"=>["1"], 
          "cmr-took"=>["10"], "cmr-request-id"=>["436b50ec-c84a-4180-93fa-9c721087d65b"], 
          "vary"=>["Accept-Encoding, User-Agent"], "connection"=>["close"], 
          "server"=>["Jetty(9.2.z-SNAPSHOT)"]
          })

      error = false
      begin
        collection = Cmr.get_collection("junk-name")
      rescue Cmr::CmrError => e
        Rails.logger.error(e.message)
        error = true
      end

      assert_equal(error, true)
    end

    it "raises error when concept_id is not found" do
      stub_request(:get, "#{@cmr_base_url}/search/collections.echo10?concept_id=C1000000042-LANCEAMSR3")
        .with(:headers => {
          'Accept'=>'*/*', 
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 
          'User-Agent'=>'Ruby'
          })
        .to_return(:status => 200, :body => '<?xml version=\"1.0\" encoding=\"UTF-8\"?><results><hits>0</hits><took>21</took></results>', :headers => {
          "date"=>["Mon, 20 Feb 2017 19:38:25 GMT"], 
          "content-type"=>["application/echo10+xml; charset=utf-8"], 
          "access-control-expose-headers"=>["CMR-Hits, CMR-Request-Id"], 
          "access-control-allow-origin"=>["*"], "cmr-hits"=>["1"], 
          "cmr-took"=>["10"], "cmr-request-id"=>["436b50ec-c84a-4180-93fa-9c721087d65b"], 
          "vary"=>["Accept-Encoding, User-Agent"], "connection"=>["close"], 
          "server"=>["Jetty(9.2.z-SNAPSHOT)"]
          })

      error = false
      begin
        collection = Cmr.get_collection("C1000000042-LANCEAMSR3")
      rescue Cmr::CmrError => e
        Rails.logger.error(e.message)
        error = true
      end

      assert_equal(error, true)
    end

    it "correctly flattens results from collection" do
      stub_request(:get, "#{@cmr_base_url}/search/collections.echo10?concept_id=C1000000020-LANCEAMSR2")
        .with(:headers => {
          'Accept'=>'*/*', 
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 
          'User-Agent'=>'Ruby'
          })
        .to_return(:status => 200, :body => get_stub("search_collections_echo10_C1000000020LANCEAMSR2.xml"), :headers => {
          "date"=>["Mon, 20 Feb 2017 19:38:25 GMT"], 
          "content-type"=>["application/echo10+xml; charset=utf-8"], 
          "access-control-expose-headers"=>["CMR-Hits, CMR-Request-Id"], 
          "access-control-allow-origin"=>["*"], "cmr-hits"=>["1"], 
          "cmr-took"=>["10"], "cmr-request-id"=>["436b50ec-c84a-4180-93fa-9c721087d65b"], 
          "vary"=>["Accept-Encoding, User-Agent"], "connection"=>["close"], 
          "server"=>["Jetty(9.2.z-SNAPSHOT)"]
          })
      collection = Cmr.get_collection("C1000000020-LANCEAMSR2")

      is_flat = true
      collection.each do |key, value|
        unless value.is_a? String
          is_flat = false
        end
      end

      assert_equal(is_flat, true)
      #asserting this so that it can be shown for next test that this key is normally available
      assert_equal((collection.keys.include? "Contacts/Contact/OrganizationEmails/Email"), true)
    end

    it "correctly adds in the dependent fields" do
      # In this stub I removed all entries for the Spatial/HorizontalSpatialDomain/Geometry
      # A bounding rectangle is expected to be added in since all collections need one type of bounding geometry
      stub_request(:get, DEPENDENT_URL)
        .with(:headers => DEFAULT_STUB_HEADERS).to_return(:status => 200, :body => DEPENDENT_BODY, :headers => DEPENDENT_HEADER)
      collection = Cmr.get_collection("C1000000020-LANCEAMSR2")

      assert collection["Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle/WestBoundingCoordinate"]
    end
  end


  describe "collection_granule_count" do

    it "gets number of associated granules" do
      stub_request(:get, "#{@cmr_base_url}/search/granules.echo10?concept_id=C1000000020-LANCEAMSR2&page_num=1&page_size=10")
        .with(:headers => {
          'Accept'=>'*/*', 
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 
          'User-Agent'=>'Ruby'
          })
        .to_return(:status => 200, :body => get_stub("search_collections_echo10_C1000000020LANCEAMSR2_2.xml"), :headers => {
          "date"=>["Mon, 20 Feb 2017 19:38:25 GMT"], 
          "content-type"=>["application/echo10+xml; charset=utf-8"], 
          "access-control-expose-headers"=>["CMR-Hits, CMR-Request-Id"], 
          "access-control-allow-origin"=>["*"], 
          "cmr-hits"=>["1"], "cmr-took"=>["10"], 
          "cmr-request-id"=>["436b50ec-c84a-4180-93fa-9c721087d65b"], 
          "vary"=>["Accept-Encoding, User-Agent"], "connection"=>["close"], 
          "server"=>["Jetty(9.2.z-SNAPSHOT)"]
          })
      granule_count = Cmr.collection_granule_count("C1000000020-LANCEAMSR2")

      assert_equal(granule_count, 29)
    end

  end

  describe "collection_search" do
    it "gets free text results from CMR" do
      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/collections.echo10?keyword=*doris*&page_num=1&page_size=10&provider=LANCEAMSR2")
        .with(headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
          })
        .to_return(:status => 200, :body => get_stub("search_collections_echo10_doris_providerLANCEAMSR2.xml"), :headers => {
          "content-type"=>["application/echo10+xml; charset=utf-8"], 
          "cmr-hits"=>["0"], "cmr-took"=>["46"], "access-control-allow-origin"=>["*"],
          "access-control-expose-headers"=>["CMR-Hits, CMR-Request-Id, X-Request-Id, CMR-Scroll-Id, CMR-Timed-Out, CMR-Shapefile-Original-Point-Count, CMR-Shapefile-Simplified-Point-Count"],
          "cmr-request-id"=>["34840e65-7813-4d27-a4d1-d9107e9cdb08"],
          "date"=>["Thu, 24 Jun 2021 16:18:51 GMT"]
          })

      search_iterator, collection_count = Cmr.collection_search("doris", nil, ApplicationHelper::ARC_PROVIDERS, 1, 10)

      assert_equal(search_iterator[0]["concept_id"], "C1000000020-CDDIS")
      assert_equal(search_iterator[1]["concept_id"], "C1000000080-CDDIS")
      assert_equal(collection_count, 40)
    end
  end

  describe "total_collection_count" do
    it "get the total number of collections from CMR" do

      stub_request(:get, "#{@cmr_base_url}/search/collections.echo10?page_size=1&provider=NSIDCV0&provider=ORNL_DAAC&provider=LARC_ASDC&provider=LARC&provider=LAADS&provider=GES_DISC&provider=GHRC&provider=SEDAC&provider=ASF&provider=LPDAAC_ECS&provider=LANCEMODIS&provider=NSIDC_ECS&provider=OB_DAAC&provider=CDDIS&provider=LANCEAMSR2&provider=PODAAC&provider=ARCTEST")
        .with(:headers => {
          'Accept'=>'*/*', 
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 
          'User-Agent'=>'Ruby'
          })
        .to_return(:status => 200, :body => '<?xml version=\"1.0\" encoding=\"UTF-8\"?><results><hits>6381</hits><took>33</took><result></result></results>', :headers => {
          "date"=>["Fri, 24 Mar 2017 15:36:33 GMT"], 
          "content-type"=>["application/echo10+xml; charset=utf-8"], 
          "access-control-expose-headers"=>["CMR-Hits, CMR-Request-Id"], 
          "access-control-allow-origin"=>["*"], "cmr-hits"=>["32728"], 
          "cmr-took"=>["33"], "cmr-request-id"=>["8633b6cd-cc02-4147-91b2-e0236fd1b72a"], 
          "vary"=>["Accept-Encoding, User-Agent"], "connection"=>["close"], 
          "server"=>["Jetty(9.2.z-SNAPSHOT)"], "strict-transport-security"=>["max-age=31536000"]
          })
      total_num = Cmr.total_collection_count(ApplicationHelper::ARC_PROVIDERS)
      assert_equal(total_num, 6381)
    end
  end

  describe "collections_updated_since" do
    it "pulls xml response from cmr and returns hash" do
      #mocking the updated list with a small representative sample result
      stub_request(:get, "#{@cmr_base_url}/search/collections.xml?page_num=1&page_size=2000&updated_since=2017-03-16T00:00:00.000Z")
        .with(:headers => {
          'Accept'=>'*/*', 
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 
          'User-Agent'=>'Ruby'
          })
        .to_return(:status => 200, :body => "<results><hits>151</hits><took>10</took><references><reference><name>All-India Monsoon Rainfall Index at LDEO/IRI Climate Data Library</name><id>C1214614350-SCIOPS</id><location>#{@cmr_base_url}:443/search/concepts/C1214614350-SCIOPS/6</location><revision-id>6</revision-id></reference><reference><name>Annual Mean Global CO2 Growth</name><id>C1214377525-SCIOPS</id><location>#{@cmr_base_url}:443/search/concepts/C1214377525-SCIOPS/2</location><revision-id>2</revision-id></reference></references></results>", :headers => {
          "date"=>["Fri, 17 Mar 2017 19:00:27 GMT"], 
          "content-type"=>["application/xml; charset=utf-8"], 
          "access-control-expose-headers"=>["CMR-Hits, CMR-Request-Id"], 
          "access-control-allow-origin"=>["*"], "cmr-hits"=>["151"], 
          "cmr-took"=>["24"], "cmr-request-id"=>["7348fbe8-5ef4-417e-969f-01024e4d9ef6"], 
          "vary"=>["Accept-Encoding, User-Agent"], "connection"=>["close"], 
          "server"=>["Jetty(9.2.z-SNAPSHOT)"], "strict-transport-security"=>["max-age=31536000"]
          })

      raw_results = Cmr.collections_updated_since("2017-03-16")
      assert_equal(raw_results, {
        "results"=>{
          "hits"=>"151", "took"=>"10", 
          "references"=>{
            "reference"=>[{
              "name"=>"All-India Monsoon Rainfall Index at LDEO/IRI Climate Data Library", 
              "id"=>"C1214614350-SCIOPS", "location"=>"#{@cmr_base_url}:443/search/concepts/C1214614350-SCIOPS/6", 
              "revision_id"=>"6"
            }, 
            {
              "name"=>"Annual Mean Global CO2 Growth", "id"=>"C1214377525-SCIOPS", 
              "location"=>"#{@cmr_base_url}:443/search/concepts/C1214377525-SCIOPS/2", "revision_id"=>"2"
            }]}}})
    end
  end

end
