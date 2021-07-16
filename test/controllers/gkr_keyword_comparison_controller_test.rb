require 'test_helper'

class GkrKeywordComparisonControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get gkr_keyword_comparison_show_url
    assert_response :success
  end

end
