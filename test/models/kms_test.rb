require 'test_helper'
require 'stub_data'

class KmsTest < ActiveSupport::TestCase
  TEST_SCHEMES = %w[sciencekeywords platforms instruments projects providers ProductLevelId GranuleDataFormat]
  setup do
    kms_base_url = Kms.get_kms_base_url
    stub_header = {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent'=>'Ruby'
    }
    stub_request(:get, "#{kms_base_url}/kms/concepts/concept_scheme/sciencekeywords?format=csv").
        with(headers: stub_header).
        to_return(status: 200, body: get_stub('sciencekeywords.csv'), headers: {})

    stub_request(:get, "#{kms_base_url}/kms/concepts/concept_scheme/platforms?format=csv").
        with(headers: stub_header).
        to_return(status: 200, body: get_stub('platforms.csv'), headers: {})

    stub_request(:get, "#{kms_base_url}/kms/concepts/concept_scheme/instruments?format=csv").
        with(headers: stub_header).
        to_return(status: 200, body: get_stub('instruments.csv'), headers: {})

    stub_request(:get, "#{kms_base_url}/kms/concepts/concept_scheme/projects?format=csv").
        with(headers: stub_header).
        to_return(status: 200, body: get_stub('projects.csv'), headers: {})

    stub_request(:get, "#{kms_base_url}/kms/concepts/concept_scheme/providers?format=csv").
        with(headers: stub_header).
        to_return(status: 200, body: get_stub('providers.csv'), headers: {})

    stub_request(:get, "#{kms_base_url}/kms/concepts/concept_scheme/ProductLevelId?format=csv").
        with(headers: stub_header).
        to_return(status: 200, body: get_stub('ProductLevelId.csv'), headers: {})

    stub_request(:get, "#{kms_base_url}/kms/concepts/concept_scheme/GranuleDataFormat?format=csv").
        with(headers: stub_header).
        to_return(status: 200, body: get_stub('granuledataformat.csv'), headers: {})

    @kms = Kms.new
    @kms.download_kms_keywords(TEST_SCHEMES)
  end

  describe "kms accessor test" do

    it "download keywords in all schemes" do
      result = @kms.get_keyword_paths('sciencekeywords')
      key = 'EARTH SCIENCE SERVICES|DATA ANALYSIS AND VISUALIZATION|CALIBRATION/VALIDATION'
      assert_equal(true, result[key])
      key = 'ATLAS'
      result = @kms.get_keyword_paths('instruments')
      assert_equal(true, result[key])
      key = 'AC-680E'
      result = @kms.get_keyword_paths('platforms')
      assert_equal(true, result[key])
      key = 'AARDDVARK'
      result = @kms.get_keyword_paths('projects')
      assert_equal(true, result[key])
      key = 'ABDN/GEOG/CMCZM'
      result = @kms.get_keyword_paths('providers')
      assert_equal(true, result[key])
      key = '2P'
      result = @kms.get_keyword_paths('ProductLevelId')
      assert_equal(true, result[key])
      key = 'GeoPackage'
      result = @kms.get_keyword_paths('GranuleDataFormat')
      assert_equal(true, result[key])
    end

    it "get kms base url" do
      kms_base_url = Kms.get_kms_base_url
      assert_equal('https://gcmd.earthdata.nasa.gov', kms_base_url)
    end

    it "get kms url for science keywords" do
      kms_url = @kms.get_kms_url('sciencekeywords')
      assert_equal('https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/sciencekeywords?format=csv', kms_url)
    end

  end
end