require 'test_helper'

class CmrSyncTest < ActiveSupport::TestCase
  describe "can read/write since data from cmr_sync table" do
    it "can read sync date" do
      assert_equal('1971-01-01T12:00:00Z', CmrSync.get_sync_date.utc.iso8601)
    end

    it "can write sync date" do
      now = DateTime.now
      CmrSync.update_sync_date(now)
      retrieved_date = CmrSync.get_sync_date
      assert_in_delta retrieved_date, DateTime.now, 10
    end

    it "returns all concept_id, revision_id, short_name, version for a given provider from CMR api" do
      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/collections.umm-json?page_num=1&page_size=30&provider=LARC&updated_since=1971-01-01T12:00:00Z").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            #
          }).
        to_return(status: 200, body: get_stub("get_umm_json_collections_larc_pg1.json"), headers: {"cmr-hits" => 32, "content-type" => "application/json;charset=utf-8"})

      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/collections.umm-json?page_num=2&page_size=30&provider=LARC&updated_since=1971-01-01T12:00:00Z").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            #
          }).
        to_return(status: 200, body: get_stub("get_umm_json_collections_larc_pg2.json"), headers: {"content-type" => "application/json;charset=utf-8"})

      concepts = CmrSync.get_concepts('LARC', page_size=30)
      (concept_id, revision_id, short_name, version) = concepts[0]
      assert_equal(concept_id, 'C28109-LARC')
      assert_equal(revision_id, 12)
      assert_equal(short_name, 'MISBR')
      assert_equal(version, '5')
      assert_equal(32, concepts.length)
    end

    it "returns umm-json collection with revision id from CMR api" do
      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/concepts/C28109-LARC/12.umm_json").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            #
          }).
        to_return(status: 200, body: get_stub("C28109-LARC.json"), headers: {"content-type" => "content-type: application/vnd.nasa.cmr.umm_results+json;version=1.16; charset=utf-8"})
      concept = CmrSync.get_concept("C28109-LARC", 12, 'umm_json')
      assert_equal(concept['ShortName'],'MISBR')
    end

    it "returns umm-json collection without revision id from CMR api" do
      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/concepts/C28109-LARC.umm_json").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            #
          }).
        to_return(status: 200, body: get_stub("C28109-LARC.json"), headers: {"content-type" => "content-type: application/vnd.nasa.cmr.umm_results+json;version=1.16; charset=utf-8"})
      concept = CmrSync.get_concept("C28109-LARC", nil, 'umm_json')
      assert_equal(concept['ShortName'],'MISBR')
    end


  end
end
