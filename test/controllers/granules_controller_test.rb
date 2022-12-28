require 'test_helper'
Dir[Rails.root.join("test/**/*.rb")].each { |f| require f }

class GranulesControllerTest < ActionController::TestCase
  include OmniauthMacros

  describe "DELETE #delete" do
    it "deletes a selected granule record from a collection" do
      user = User.find_by role: "admin"
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      user = User.find_by role: "admin"
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      # This test first retrieves how many granules revisions exist for a given collection.
      # Then removes  the record id #16
      # It then asserts that the no granule records left is 1 less.
      collection = Collection.find(1)
      granule = collection.granules.first
      record = granule.records.find(16)
      no_granules_before = granule.records.count
      delete :destroy, params: { id: granule.id, record_id: record.id }
      no_granules_after = granule.records.count
      assert_equal no_granules_after, (no_granules_before - 1)

      assert_equal "Granule has been deleted.", flash[:notice]
    end
  end

  describe "POST #create" do
    it "creates a new random echo10 granule for a collection" do

      stub_request(:get, /.*granules\.umm_json\?collection_concept_id=.*/).
        with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          }).
        to_return(status: 200, body: get_stub('search_granules_by_collection_C1000000020-LANCEAMSR2a.json'), headers: {})

      stub_request(:get, /.*granules\.echo10\?concept_id=G.*/).
        with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',

          }).
        to_return(status: 200, body: get_stub('search_granules_G1581545525-LANCEAMSR2.xml'), headers: {})

      stub_request(:get, /.*granules.umm_json\?concept_id\=G.*/).
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: get_stub('search_granules_G1581545525-LANCEAMSR2.json'), headers: {})

      user = User.find_by role: "admin"
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      # This test grabs the collection with id #1, calls POST create which in turn pulls a random granule from
      # CMR and associates it with this collection.   If successful, the # of granules for this collection
      # should increase by 1.
      collection = Collection.find(1)
      no_granules_before = collection.granules.count
      post :create, params: { id: collection.id }
      no_granules_after = collection.granules.count
      assert_equal no_granules_after, (no_granules_before + 1)
      assert_equal "A new random granule has been added for this collection", flash[:notice]
    end

    it "creates a new random umm-g granule for a collection" do
      stub_request(:get, /.*granules\.umm_json\?collection_concept_id=.*/).
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: get_stub('search_granules_by_collection_ummg.json'), headers: {})

      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/concepts/G1581545525-LANCEAMSR2.umm_json").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: "", headers: {})


      user = User.find_by role: "admin"
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      # This test grabs the collection with id #1, calls POST create which in turn pulls a random granule from
      # CMR and associates it with this collection.   If successful, the # of granules for this collection
      # should increase by 1.
      collection = Collection.find(1)
      no_granules_before = collection.granules.count
      Quarc.stub_any_instance(:validate, {}) do
        post :create, params: { id: collection.id }
      end
      no_granules_after = collection.granules.count
      assert_equal no_granules_after, (no_granules_before + 1)
      assert_equal "A new random granule has been added for this collection", flash[:notice]
    end
  end

  describe 'POST #pull_latest' do
    it 'pulls in the latest revision of a echo10 granule for a collection.' do
      stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC").
        with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',

          }).
        to_return(status: 200, body: get_stub('search_granules_G309210-GHRC.xml'), headers: {})
      stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.umm_json?concept_id=G309210-GHRC").
        with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          }).
        to_return(status: 200, body: get_stub('search_granules_G309210-GHRC.json'), headers: {})

      user = User.find_by role: 'admin'
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      # before we do post, there should be 2 granule revisions, 1 and 6
      granule = Granule.first
      records = granule.records
      array = records.map { |a| a.revision_id }
      assert_includes array, '1'
      assert_includes array, '6'
      assert_not_includes array, '25'

      post :pull_latest, params: { id: granule.id }

      # after we do post, there should be 3 granule revisions, 1,6, and the new
      # revision stubbed above, #25
      granule = Granule.first
      records = granule.records
      array = records.map { |a| a.revision_id }
      assert_equal 'A new granule revision has been added for this collection.', flash[:notice]
      assert_includes array, '25'
    end

    it 'pulls in the latest revision of a umm-g granule for a collection.' do
      stub_request(:get, /.*granules\.umm_json\?collection_concept_id=.*/).
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: get_stub('search_granules_by_collection_ummg.json'), headers: {})

      stub_request(:get, /.*granules.umm_json\?concept_id\=G.*/).
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: get_stub('search_granules_ummg.json'), headers: {})

      user = User.find_by role: 'admin'
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      # before we do post, there should be 2 granule revisions, 1 and 6
      granule = Granule.first
      records = granule.records
      array = records.map { |a| a.revision_id }
      assert_includes array, '1'
      assert_includes array, '6'
      assert_not_includes array, '25'

      post :pull_latest, params: { id: granule.id }

      # after we do post, there should be 3 granule revisions, 1,6, and the new
      # revision stubbed above, #15
      granule = Granule.first
      records = granule.records
      array = records.map { |a| a.revision_id }
      assert_equal 'A new granule revision has been added for this collection.', flash[:notice]
      assert_includes array, '15'
    end
  end

  describe "DELETE #replace" do
    it "prevents DAAC curators from replacing the Granule" do
      user = User.find_by role: "daac_curator"
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      granule = Granule.first
      record = granule.records.find(5)

      # This method ensures that DAAC curators can not replace granule records.
      delete :replace, params: { id: granule.id, record_id: record.id }

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
    #   delete :replace, params: { id: granule.id, record_id: record.id }
    #
    #   assert_redirected_to collection_path(id: 1, record_id: collection.records.first.id)
    #   assert_equal "This granule is in review, and can no longer be changed to a different granule", flash[:alert]
    # end

    it "will delete and replace the granule" do
      user = User.find_by role: "admin"
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      granule = Granule.first
      record = granule.records.find(16)
      collection = granule.collection

      Granule.any_instance.expects(:destroy)
      Collection.any_instance.expects(:add_granule)

      delete :replace, params: { id: granule.id, record_id: record.id }

      assert_redirected_to collection_path(id: 1, record_id: collection.records.first.id)
      assert_equal "A new granule has been selected for this collection", flash[:notice]
    end
  end

  describe "POST #ingest_specific" do
    it "can ingest a specifc echo10 granule review not found in CMR" do
      user = User.find_by(role: "admin")
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=somegranule").
        with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',

          }).
        to_return(status: 200, body: get_stub('search_granules_G309210-GHRC.xml'), headers: {})
      stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.umm_json?concept_id=somegranule").
        with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          }).
        to_return(status: 200, body: get_stub('search_granules_G309210-GHRC.json'), headers: {})

      post :ingest_specific, params: { id: 1, granule_concept_id: "somegranule" }
      assert_equal 'Granule somegranule ingested.', flash[:notice]
    end

    it "can ingest a specific umm-g granule review not found in CMR" do
      user = User.find_by(role: "admin")
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      stub_request(:get, /.*granules\.umm_json\?collection_concept_id=.*/).
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: get_stub('search_granules_by_collection_ummg.json'), headers: {})

      stub_request(:get, /.*granules.umm_json\?concept_id=somegranule/).
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: get_stub('search_granules_ummg.json'), headers: {})

      post :ingest_specific, params: { id: 1, granule_concept_id: "somegranule" }
      assert_equal 'Granule somegranule ingested.', flash[:notice]
    end

    it "can ingest a specific granule review found in CMR and test that you cannot import the granule again (duplicate)" do
      user = User.find_by(role: "admin")
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.umm_json?concept_id=G226250-GHRC").
        with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          }).
        to_return(status: 200, body: get_stub("search_granules_G226250-GHRC.json"), headers: {})
      stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.umm_json?concept_id=G226251-GHRC").
        with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          }).
        to_return(status: 200, body: get_stub("search_granules_G226251-GHRC.json"), headers: {})

      stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=G226251-GHRC").
        with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',

          }).
        to_return(status: 200, body: get_stub("search_granules_G226251-GHRC.xml"), headers: {})

      post :ingest_specific, params: { id: 1, granule_concept_id: "G226251-GHRC" }
      assert_equal 'Granule G226251-GHRC ingested.', flash[:notice]
      post :ingest_specific, params: { id: 1, granule_concept_id: "G226251-GHRC" }
      assert_equal 'Sorry, granule review G226251-GHRC already exists!', flash[:notice]

    end
  end
end
