require 'test_helper'

class AclsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get acls_index_url
    assert_response :success
  end

end
