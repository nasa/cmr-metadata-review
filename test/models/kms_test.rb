require 'test_helper'
require 'stub_data'

class KmsTest < ActiveSupport::TestCase
  TEST_SCHEMES = %w[sciencekeywords platforms instruments projects providers ProductLevelId]
  setup do
    stub_header = {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent'=>'Ruby'
    }
    stub_request(:get, "https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/sciencekeywords?format=csv").
        with(headers: stub_header).
        to_return(status: 200, body: get_stub('sciencekeywords.csv'), headers: {})

    stub_request(:get, "https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/platforms?format=csv").
        with(headers: stub_header).
        to_return(status: 200, body: get_stub('platforms.csv'), headers: {})

    stub_request(:get, "https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/instruments?format=csv").
        with(headers: stub_header).
        to_return(status: 200, body: get_stub('instruments.csv'), headers: {})

    stub_request(:get, "https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/projects?format=csv").
        with(headers: stub_header).
        to_return(status: 200, body: get_stub('projects.csv'), headers: {})

    stub_request(:get, "https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/providers?format=csv").
        with(headers: stub_header).
        to_return(status: 200, body: get_stub('providers.csv'), headers: {})

    stub_request(:get, "https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/ProductLevelId?format=csv").
        with(headers: stub_header).
        to_return(status: 200, body: get_stub('ProductLevelId.csv'), headers: {})
    @kms = Kms.new
    @kms.download_kms_keywords(TEST_SCHEMES)
  end

  describe "kms accessor" do

    it "download keywords in all schemes" do
      result = @kms.get_keyword_paths('sciencekeywords')
      assert_equal('EARTH SCIENCE SERVICES|DATA ANALYSIS AND VISUALIZATION|CALIBRATION/VALIDATION', result[1])
      result = @kms.get_keyword_paths('instruments')
      assert_equal('ATLAS', result[1])
      result = @kms.get_keyword_paths('platforms')
      assert_equal('AC-680E', result[2])
      result = @kms.get_keyword_paths('projects')
      assert_equal('AARDDVARK', result[4])
      result = @kms.get_keyword_paths('providers')
      assert_equal('ABDN/GEOG/CMCZM', result[4])
      result = @kms.get_keyword_paths('ProductLevelId')
      assert_equal('2P', result[6])
    end

    it "get kms base url" do
      kms_base_url = @kms.get_kms_base_url
      assert_equal('https://gcmd.earthdata.nasa.gov', kms_base_url)
    end

    it "get kms url for science keywords" do
      kms_url = @kms.get_kms_url('sciencekeywords')
      assert_equal('https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/sciencekeywords?format=csv', kms_url)
    end

  end
end