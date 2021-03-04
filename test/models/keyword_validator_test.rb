require 'test_helper'
require 'stub_data'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class KeywordValidatorTest < ActiveSupport::TestCase
  include Helpers::UserHelpers

  TEST_PROVIDERS = %w[SCIOPS]

  setup do
    OmniAuth.config.test_mode = true
    mock_login(role: 'arc_curator')

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

    cmr_base_url = Cmr.get_cmr_base_url
    stub_header_faraday = {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent'=>'Faraday v0.15.3'
    }
    stub_request(:get, "#{cmr_base_url}/search/collections.umm-json?page_num=1&page_size=2000&provider=SCIOPS&updated_since=1971-01-01T12:00:00Z").
        with(headers: stub_header_faraday).
        to_return(status: 200, body: get_stub('keyword_validator_get_concepts.json'), headers: {})

    stub_request(:get, "#{cmr_base_url}/search/concepts/C1200207458-SCIOPS/1.umm_json").
        with(headers: stub_header).
        to_return(status: 200, body: get_stub('keyword_validator_get_concept_C1200207458-SCIOPS.json'), headers: {})

    stub_request(:get, "#{cmr_base_url}/search/concepts/C1200208767-SCIOPS/1.umm_json").
        with(headers: stub_header).
        to_return(status: 200, body: get_stub('keyword_validator_get_concept_C1200208767-SCIOPS.json'), headers: {})
  end
  describe 'keyword validator test' do
    it 'validate keyword' do
      KeywordValidator.validate_keywords(TEST_PROVIDERS)
      assert_equal(InvalidKeyword.all.length, 9)
    end
  end
end