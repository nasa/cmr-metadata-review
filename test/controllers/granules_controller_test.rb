require 'test_helper'

class GranulesControllerTest < ActionController::TestCase

  setup do
    Cmr.stubs(:get_user_info).with{ |*args| args[0]}.returns [200, nil]
    Cmr.stubs(:get_access_token_and_refresh_token).with{|*args| args[0]}.returns ['abc', 'def']
  end

  describe "DELETE #replace" do
    it "prevents DAAC curators from replacing the Granule" do
      user = User.find_by role: "daac_curator"
      sign_in(user)

      granule = Granule.first
      record  = granule.records.find(5)

      delete :replace, id: granule.id, record_id: record.id

      assert_redirected_to general_home_path
      assert_equal "You are not authorized to access this page.", flash[:alert]
    end


    # Removed this test until a better workflow is designed, right now you can't reopen a record, to allow you to
    # ingest it.
    #
    # it "prevents replacement on Granules in review" do
    #   user = User.find_by role: "admin"
    #   sign_in(user)
    #
    #   granule = Granule.first
    #   record  = granule.records.find(5)
    #   collection = granule.collection
    #
    #   delete :replace, id: granule.id, record_id: record.id
    #
    #   assert_redirected_to collection_path(id: 1, record_id: collection.records.first.id)
    #   assert_equal "This granule is in review, and can no longer be changed to a different granule", flash[:alert]
    # end

    it "will delete and replace the granule" do
      user = User.find_by role: "admin"
      sign_in(user)

      granule = Granule.first
      record  = granule.records.find(16)
      collection = granule.collection

      Granule.any_instance.expects(:destroy)
      Collection.any_instance.expects(:add_granule)

      delete :replace, id: granule.id, record_id: record.id

      assert_redirected_to collection_path(id: 1, record_id: collection.records.first.id)
      assert_equal "A new granule has been selected for this collection", flash[:notice]
    end
  end
end
