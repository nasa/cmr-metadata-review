require 'test_helper'
require 'stub_data'

class KeywordCheckerTest < ActiveSupport::TestCase
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

    json_record = get_stub('keyword_checker_C1625703857-LAADS.json')
    @record = JSON.parse(json_record)
    @keyword_checker = KeywordChecker.new()
  end
  describe 'KeywordChecker test' do
    it 'get keywords from json' do
      keywords = @keyword_checker.get_record_keywords(@record, 'sciencekeywords')
      assert_equal('EARTH SCIENCE|SPECTRAL/ENGINEERING|VISIBLE WAVELENGTHS|VISIBLE IMAGERY', keywords[1])
      keywords = @keyword_checker.get_record_keywords(@record, 'platforms')
      assert_equal('NASA ER-2', keywords[0])
      keywords = @keyword_checker.get_record_keywords(@record, 'instruments')
      assert_equal('MAS', keywords[0])
      assert_equal('CALIOP', keywords[1])
      keywords = @keyword_checker.get_record_keywords(@record, 'providers')
      assert_equal('NASA/GSFC/SED/ESD/HBSL/BISB/LAADS', keywords[0])
      keywords = @keyword_checker.get_record_keywords(@record, 'projects')
      assert_equal('WINCE', keywords[1])
      keywords = @keyword_checker.get_record_keywords(@record, 'ProductLevelId')
      assert_equal('1B', keywords[0])
    end

    it 'get invalid keywords' do
      invalid_keywords = @keyword_checker.get_invalid_keywords(@record, 'sciencekeywords')
      assert_equal('EARTH SCIENCE|SPECTRAL/ENGINEERING|VISIBLE WAVELENGTHS|VISIBLE IMAGERY TEST', invalid_keywords[0])
      invalid_keywords = @keyword_checker.get_invalid_keywords(@record, 'instruments')
      assert_equal('MAS', invalid_keywords[0])
    end

  end
end