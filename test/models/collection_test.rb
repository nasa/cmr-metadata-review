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
end
