require 'test_helper'

class InvalidKeywordsControllerTest < ActionController::TestCase
  describe 'GET #invalid_keywords' do
    it 'produces csv report for all providers' do
      get :csv_report, params: { format: :csv }
      assert_includes @response['Content-Type'], 'text/csv'
      assert_equal((response.body.include? "NSIDC,concept_id2"), true)
      assert_equal((response.body.include? "LARC,concept_id1"), true)
    end

    it 'produces csv report for specified provider' do
      get :csv_report, params: { format: :csv, provider: 'NSIDC' }
      assert_includes @response['Content-Type'], 'text/csv'
      assert_equal((response.body.include? "NSIDC,concept_id2"), true)
      assert_equal((response.body.include? "LARC,concept_id1"), false)
    end

  end
end
