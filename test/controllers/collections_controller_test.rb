class CollectionsControllerTest < ActionController::TestCase
    describe "GET #show" do
      context "when successful" do
        it "loads the correct collection on show" do
            @tester = User.find_by_email("abaker@element84.com")
            sign_in(@tester)

            get :show, id: 1, concept_id: "C1000000020-LANCEAMSR2"

            collection_records = assigns(:collection_records)
            assert_equal(collection_records.length, 1)
        end
      end
      context "when no concept id is provided" do
        it "redirects" do
            #redirects no concept_id
            get :show, id: 1
            assert_equal(response.code, "302")
        end
      end
      context "when no collection is found" do
        it "redirects" do
            #redirects no collection found
            get :show, id: 1, concept_id: "xyz"
            assert_equal(response.code, "302")
        end
      end
    end
end