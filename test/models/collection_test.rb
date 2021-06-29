require 'test_helper'

class RecordTest < ActiveSupport::TestCase

  describe "parsing collection urls" do
    it "returns concept id, revision id, and format" do
      concept_id, revision_id, data_format = Collection.parse_collection_url("https://cmr.sit.earthdata.nasa.gov/search/concepts/C1000000443-NSIDC_ECS/3.echo10")
      assert_equal(concept_id, "C1000000443-NSIDC_ECS")
      assert_equal(revision_id, "3")
      assert_equal(data_format, "echo10")

      concept_id, revision_id, data_format = Collection.parse_collection_url("https://cmr.sit.earthdata.nasa.gov:443/search/concepts/C1000000443-NSIDC_ECS/3.echo10")
      assert_equal(concept_id, "C1000000443-NSIDC_ECS")
      assert_equal(revision_id, "3")
      assert_equal(data_format, "echo10")
    end
  end

  describe "GET #record" do
    it "creates a new record by url" do
      stub_request(:get, "https://cmr.earthdata.nasa.gov/search/concepts/C1652975935-PODAAC.echo10")
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent' => 'Ruby'
            }
          )
          .to_return(status: 200, body: get_stub('search_concepts_C1652975935PODAAC_echo10.xml'), headers: {'content-type': 'application/echo10+xml; charset=utf-8'})

          
    end
  end
end
