require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each {|f| require f}

class RecordsControllerTest < ActionController::TestCase
  include OmniauthMacros

  setup do
    @controller = RecordsController.new
  end

  describe 'POST #create' do
    it 'updates record data from review params' do
      @tester = User.find_by_email('abaker@element84.com')
      sign_in(@tester)
      stub_urs_access(@tester.uid, @tester.access_token, @tester.refresh_token)

      #sample update params
      #posting with a record id param of 1
      post :update, params: { 'redirect_index'=>'0', 'recommendation'=>{ 'ShortName'=>'', 'VersionId'=>'not ok', 'LongName'=>'ok' }, 'opinion'=>{ 'VersionId'=>'on' }, 'color_code'=>{ 'ShortName'=>'', 'VersionId'=>'red', 'LongName'=>'' }, 'discussion'=>{ 'ShortName'=>'', 'VersionId'=>'', 'LongName'=>'new comment' }, 'utf8'=>'✓', '_method'=>'put', 'authenticity_token'=>'testtoken', 'section_index'=>'0', 'commit'=>'Save Review', 'controller'=>'records', 'action'=>'update', 'id'=>'1' }

      record = Record.find_by id: 1
      #broken out sections of params below to compare to tests
      #all positive tests, making sure that desired additions appear

      assert_equal(record.get_recommendations['VersionId'], 'not ok')
      assert_equal(record.get_recommendations['ShortName'], '')
      assert_equal(record.get_recommendations['LongName'], 'ok')

      assert_equal(record.get_opinions['VersionId'], true)

      assert_equal(record.get_colors['VersionId'], 'red')
      assert_equal(record.get_colors['ShortName'], '')
      assert_equal(record.get_colors['LongName'], '')

      assert_equal(record.get_opinions['VersionId'], true)

      #"discussion"=>{"ShortName"=>"", "VersionId"=>"", "InsertTime"=>"", "LastUpdate"=>"", "LongName"=>"new comment", "DataSetId"=>"", "Description"=>"", "CollectionDataType"=>"", "Orderable"=>"", "Visible"=>"", "ProcessingLevelId"=>"", "ArchiveCenter"=>"", "CitationForExternalPublication"=>"", "Price"=>"", "SpatialKeywords/Keyword"=>"", "TemporalKeywords/Keyword"=>"", "AssociatedDIFs/DIF/EntryId"=>"", "MetadataStandardName"=>"", "MetadataStandardVersion"=>"", "DatasetId"=>"", "DataFormat"=>""}
      assert_equal(record.discussions.where(column_name: 'LongName').sort_by(&:date).first.comment, 'new comment')
    end

    it 'removes values when unselected' do
      @tester = User.find_by_email('abaker@element84.com')
      sign_in(@tester)
      stub_urs_access(@tester.uid, @tester.access_token, @tester.refresh_token)

      #using the same post data from update record test
      post :update, params: { 'redirect_index'=>'0', 'recommendation'=>{ 'ShortName'=>'', 'VersionId'=>'not ok', 'InsertTime'=>'ok', 'LastUpdate'=>'ok', 'LongName'=>'', 'DataSetId'=>'', 'Description'=>'', 'CollectionDataType'=>'', 'Orderable'=>'', 'Visible'=>'', 'ProcessingLevelId'=>'', 'ArchiveCenter'=>'', 'CitationForExternalPublication'=>'', 'Price'=>'', 'SpatialKeywords/Keyword'=>'', 'TemporalKeywords/Keyword'=>'', 'AssociatedDIFs/DIF/EntryId'=>'', 'MetadataStandardName'=>'', 'MetadataStandardVersion'=>'', 'DatasetId'=>'', 'DataFormat'=>'' }, 'opinion'=>{ 'InsertTime'=>'on' }, 'color_code'=>{ 'ShortName'=>'', 'VersionId'=>'red', 'InsertTime'=>'green', 'LastUpdate'=>'green', 'LongName'=>'', 'DataSetId'=>'', 'Description'=>'', 'CollectionDataType'=>'', 'Orderable'=>'', 'Visible'=>'', 'ProcessingLevelId'=>'', 'ArchiveCenter'=>'', 'CitationForExternalPublication'=>'', 'Price'=>'', 'SpatialKeywords/Keyword'=>'', 'TemporalKeywords/Keyword'=>'', 'AssociatedDIFs/DIF/EntryId'=>'', 'MetadataStandardName'=>'', 'MetadataStandardVersion'=>'', 'DatasetId'=>'', 'DataFormat'=>'' }, 'discussion'=>{ 'ShortName'=>'', 'VersionId'=>'', 'InsertTime'=>'', 'LastUpdate'=>'', 'LongName'=>'new comment', 'DataSetId'=>'', 'Description'=>'', 'CollectionDataType'=>'', 'Orderable'=>'', 'Visible'=>'', 'ProcessingLevelId'=>'', 'ArchiveCenter'=>'', 'CitationForExternalPublication'=>'', 'Price'=>'', 'SpatialKeywords/Keyword'=>'', 'TemporalKeywords/Keyword'=>'', 'AssociatedDIFs/DIF/EntryId'=>'', 'MetadataStandardName'=>'', 'MetadataStandardVersion'=>'', 'DatasetId'=>'', 'DataFormat'=>'' }, 'utf8'=>'✓', '_method'=>'put', 'authenticity_token'=>'testtoken', 'section_index'=>'0', 'commit'=>'Save Review', 'controller'=>'records', 'action'=>'update', 'id'=>'1' }

      #now posting new empty params to clear choices
      post :update, params: { 'redirect_index'=>'0', 'recommendation'=>{ 'ShortName'=>'', 'VersionId'=>'', 'InsertTime'=>'', 'LastUpdate'=>'', 'LongName'=>'', 'DataSetId'=>'', 'Description'=>'', 'CollectionDataType'=>'', 'Orderable'=>'', 'Visible'=>'', 'ProcessingLevelId'=>'', 'ArchiveCenter'=>'', 'CitationForExternalPublication'=>'', 'Price'=>'', 'SpatialKeywords/Keyword'=>'', 'TemporalKeywords/Keyword'=>'', 'AssociatedDIFs/DIF/EntryId'=>'', 'MetadataStandardName'=>'', 'MetadataStandardVersion'=>'', 'DatasetId'=>'', 'DataFormat'=>'' }, 'opinion'=>{}, 'color_code'=>{ 'ShortName'=>'', 'VersionId'=>'', 'InsertTime'=>'', 'LastUpdate'=>'', 'LongName'=>'', 'DataSetId'=>'', 'Description'=>'', 'CollectionDataType'=>'', 'Orderable'=>'', 'Visible'=>'', 'ProcessingLevelId'=>'', 'ArchiveCenter'=>'', 'CitationForExternalPublication'=>'', 'Price'=>'', 'SpatialKeywords/Keyword'=>'', 'TemporalKeywords/Keyword'=>'', 'AssociatedDIFs/DIF/EntryId'=>'', 'MetadataStandardName'=>'', 'MetadataStandardVersion'=>'', 'DatasetId'=>'', 'DataFormat'=>'' }, 'discussion'=>{ 'ShortName'=>'', 'VersionId'=>'', 'InsertTime'=>'', 'LastUpdate'=>'', 'LongName'=>'', 'DataSetId'=>'', 'Description'=>'', 'CollectionDataType'=>'', 'Orderable'=>'', 'Visible'=>'', 'ProcessingLevelId'=>'', 'ArchiveCenter'=>'', 'CitationForExternalPublication'=>'', 'Price'=>'', 'SpatialKeywords/Keyword'=>'', 'TemporalKeywords/Keyword'=>'', 'AssociatedDIFs/DIF/EntryId'=>'', 'MetadataStandardName'=>'', 'MetadataStandardVersion'=>'', 'DatasetId'=>'', 'DataFormat'=>'' }, 'utf8'=>'✓', '_method'=>'put', 'authenticity_token'=>'testtoken', 'section_index'=>'0', 'commit'=>'Save Review', 'controller'=>'records', 'action'=>'update', 'id'=>'1' }

      record = Record.find_by id: 1
      #broken out sections of params below to compare to tests
      #all positive tests, making sure that desired additions appear

      assert_equal(record.get_recommendations['VersionId'], '')
      assert_equal(record.get_recommendations['ShortName'], '')
      assert_equal(record.get_recommendations['LongName'], '')

      assert_equal(record.get_opinions['VersionId'], false)

      assert_equal(record.get_colors['VersionId'], '')
      assert_equal(record.get_colors['ShortName'], '')
      assert_equal(record.get_colors['LongName'], '')

      #discussion should not be changed, checking to ensure its still there.
      assert_equal(record.discussions.where(column_name: 'LongName').sort_by(&:date).first.comment, 'new comment')
    end
  end

  describe 'POST #complete' do
    it 'will set an error when the user does not have permission to advance the record' do
      user = User.find_by(email: 'arc_curator@element84.com')
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      record = Record.find(12)

      post :complete, params: { id: record.id }

      assert_equal 'You do not have permission to perform this action', flash[:alert]
      assert_redirected_to record_path(record)
    end

    it 'will set an error when record cannot move to the next stage' do
      user = User.find_by(email: 'abaker@element84.com')
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      Record.any_instance.stubs(color_coding_complete?: false)
      record = Record.find(13)

      post :complete, params: { id: record.id }

      assert_equal 'Not all columns have been flagged with a color, cannot close review.', flash[:alert]
      assert_redirected_to record_path(record.id)
    end

    it "will send the user to the collection's page when successful" do
      user = User.find_by(email: 'abaker@element84.com')
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      Record.any_instance.stubs(close!: true)
      record = Record.find(12)

      post :complete, params: { id: record.id }

      assert_equal 'Record has been successfully updated.', flash[:notice]
      assert_redirected_to collection_path(id: 1, record_id: record.id)
    end

    it 'associates a granule to a collection' do
      user = User.find_by(email: 'abaker@element84.com')
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      Record.any_instance.stubs(close!: true)
      record = Record.find(1)

      post :associate_granule_to_collection, params: { id: record.id, associated_granule_value: 16 }

      assert_equal 'Granule G309210-GHRC/6 has been successfully associated to this collection revision 8. ', flash[:notice]
      assert_redirected_to collection_path(id: 1, record_id: record.id)
    end

    it 'displays a failure message when attempting to associate a granule to a collection record that has been closed.' do
      user = User.find_by(email: 'abaker@element84.com')
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      Record.any_instance.stubs(close!: true)
      record = Record.find(15)

      post :associate_granule_to_collection, params: { id: record.id, associated_granule_value: 16  }

      assert_equal "Can't associate collection to granule. Only open and in review collection records can be associated.", flash[:alert]
      assert_redirected_to collection_path(id: 7, record_id: record.id)
    end

    it 'roundtrip release to daac both a collection and assoc granule record and then revert it' do
      user = User.find_by(role: 'admin')
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)
      assert_equal Record.find(18).state, 'ready_for_daac_review'
      assert_equal Record.find(19).state, 'ready_for_daac_review'
      post :associate_granule_to_collection, params: { id: 18, associated_granule_value: 19 }
      assert_equal 'Granule G309210-GHRC/21 has been successfully associated to this collection revision 20. ', flash[:notice]
      post :complete, params: { id: 18 }
      assert_equal 'Record has been successfully updated.', flash[:notice]
      assert_equal Record.find(18).state, 'in_daac_review'
      assert_equal Record.find(19).state, 'in_daac_review'
      post :revert, params: { id: 18 }
      assert_equal 'The record C1000000020-LANCEAMSR2 was successfully updated.', flash[:notice]
      assert_equal Record.find(18).state, 'ready_for_daac_review'
      assert_equal Record.find(19).state, 'ready_for_daac_review'
    end

    it 'roundtrip release to daac just a collection record with no assoc granule record and then revert it' do
      user = User.find_by(role: 'admin')
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)
      assert_nil Record.find(18).released_to_daac_date
      assert_equal Record.find(18).state, 'ready_for_daac_review'
      post :complete, params: { id: 18 }
      assert_in_delta Record.find(18).released_to_daac_date, Time.zone.now, 10
      assert_equal 'Record has been successfully updated.', flash[:notice]
      assert_equal Record.find(18).state, 'in_daac_review'
      post :revert, params: { id: 18 }
      assert_nil Record.find(18).released_to_daac_date
      assert_equal 'The record C1000000020-LANCEAMSR2 was successfully updated.', flash[:notice]
      assert_equal Record.find(18).state, 'ready_for_daac_review'
    end

    it 'marks complete while checking BOTH the collection review AND the associated granule review.' do
      user = User.find_by(email: 'arc_curator@element84.com')
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)
      record = Record.find(1)
      post :associate_granule_to_collection, params: { id: record.id, associated_granule_value: 16 }
      assert_equal 'Granule G309210-GHRC/6 has been successfully associated to this collection revision 8. ', flash[:notice]
      post :complete, params: { id: record.id }
      assert_equal 'Not all columns in the associated granule have been flagged with a color!<br>The associated granule needs two completed reviews.', flash[:alert]
      assert_equal 'Record failed to update.', flash[:notice]
    end

    it 'will not flag second opinions until it hits ready for daac review state.' do
      user = User.find_by(email: 'arc_curator@element84.com')
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)
      record = Record.find(1)
      post :associate_granule_to_collection, params: { id: record.id, associated_granule_value: 16 }
      assert_equal 'Granule G309210-GHRC/6 has been successfully associated to this collection revision 8. ', flash[:notice]

      # current record is in "in_arc_review, second opinions check not flagged
      post :complete, params: { id: record.id }
      assert_no_match 'Some columns in the associated granule still need a second opinion review', flash[:alert]

      # current record now in "ready_for_daac_review"", second opinions check is flagged
      record.update(state: 'ready_for_daac_review')
      post :complete, params: { id: record.id }
      assert_match 'Some columns in the associated granule still need a second opinion review', flash[:alert]
      assert_equal 'Record failed to update.', flash[:notice]
    end

    it 'will moves the granule review state forward along with the collection view' do
      user = User.find_by(email: 'arc_curator@element84.com')
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)
      record = Record.find(1)
      post :associate_granule_to_collection, params: { id: record.id, associated_granule_value: 16 }
      assert_equal 'Granule G309210-GHRC/6 has been successfully associated to this collection revision 8. ', flash[:notice]

      # Update color for granule record data
      r = RecordData.find_by id: 35
      r.update(color: 'red')

      # Assign additional review to granule
      granule_review = Record.find(16).add_review(2)
      granule_review.mark_complete

      # Update color for collection record data
      r = RecordData.find_by id: 9
      r.update(color: 'red')

      # Assign additional review to collection
      collection_review = Record.find(1).add_review(2)
      collection_review.mark_complete

      # No errors, so complete should move it to ready_for_daac_review
      post :complete, params: { id: record.id }
      assert Record.find(1).state, Record.find(16).state
      assert Record.find(1).state, 'ready_for_daac_review'
    end


  end

  describe 'POST #revert ' do
    it 'can reopen a closed record' do
      user = User.find_by(role: 'admin')
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      record = Record.find(15)
      assert_equal Record::STATE_CLOSED.to_s, record.state
      post :revert, params: { id: record.id }
      record = Record.find(15)
      assert_equal Record::STATE_IN_DAAC_REVIEW.to_s, record.state
    end
    it "reverting a record not 'in daac review' or 'closed' results in no change" do
      user = User.find_by(role: 'admin')
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      record = Record.find(13)
      assert_equal Record::STATE_IN_ARC_REVIEW.to_s, record.state
      post :revert, params: { id: record.id }
      assert_equal 'Sorry, encountered an error reverting C1000000020-LANCEAMSR2', flash[:notice]
      record = Record.find(13)
      assert_equal Record::STATE_IN_ARC_REVIEW.to_s, record.state
    end

    it 'revert both collection and assoc granule record' do
      user = User.find_by(role: 'admin')
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)
      assert_equal Record.find(12).state, 'in_daac_review'
      assert_equal Record.find(17).state, 'in_daac_review'
      post :associate_granule_to_collection, params: { id: 12, associated_granule_value: 17 }
      assert_equal 'Granule G309210-GHRC/19 has been successfully associated to this collection revision 9. ', flash[:notice]
      post :revert, params: { id: 12 }
      assert_equal 'The record C1000000020-LANCEAMSR2 was successfully updated.', flash[:notice]
      assert_equal Record.find(12).state, 'ready_for_daac_review'
      assert_equal Record.find(17).state, 'ready_for_daac_review'
    end

    it 'can revert a record from in daac review back to ready for daac review' do
      user = User.find_by(role: 'admin')
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      record = Record.find(12)
      assert_equal Record::STATE_IN_DAAC_REVIEW.to_s, record.state
      post :revert, params: { id: record.id }
      assert_equal 'The record C1000000020-LANCEAMSR2 was successfully updated.', flash[:notice]
      record = Record.find(12)
      assert_equal Record::STATE_READY_FOR_DAAC_REVIEW.to_s, record.state
    end
  end

  describe 'POST #destroy' do
    it 'deletes the record' do
      user = User.find_by(role: 'admin')
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      record = Record.find(1)
      assert_difference('Record.count', -1) do
        delete :destroy, params: { id: record.id }
      end

      assert_redirected_to root_path
      assert_equal 'Collection was successfully deleted.', flash[:notice]
    end
  end

  describe 'POST#refresh' do

    # I've mocked a cmr response that returns a revision id 21 which is a newer revision that currently in fixtures.   The test
    # should post to Records#refresh and it should find this record, detect it is newer and ingest the new record.
    it 'refresh record with id # with new record from cmr' do
      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/concepts/C1000000020-LANCEAMSR2.umm_json").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: get_stub('search_collections.umm_json_raw_C1000000020-LANCEAMSR2.json'), headers: {})
      stub_request(:get, "#{Cmr.get_cmr_base_url}/search/collections.umm-json?page_num=1&page_size=2000&updated_since=1971-01-01T12:00:00-04:00").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            # #
          }).
        to_return(status: 200, body: get_stub('search_collections.umm-json_C1000000020-LANCEAMSR2.json'), headers: { 'cmr-hits':1 } )

      stub_request(:get, "#{Cmr.get_cmr_base_url}/search/collections.atom?concept_id=C1000000020-LANCEAMSR2").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            # #
          }).
        to_return(status: 200, body: get_stub('search_collections.atom_C1000000020-LANCEAMSR2.xml'), headers: {})

      stub_request(:get, "#{Cmr.get_cmr_base_url}/search/collections.umm_json?concept_id=C1000000020-LANCEAMSR2").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            # #
          }).
        to_return(status: 200, body: get_stub('search_collections.umm_json_raw_C1000000020-LANCEAMSR2.json'), headers: {})

      user = User.find_by(role: 'admin')
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      collection = Collection.find_by concept_id: 'C1000000020-LANCEAMSR2'
      records = collection.records
      array = records.map(&:revision_id)
      assert_not_includes array, '21'
      Quarc.stub_any_instance(:validate, {}) do
        post :refresh
      end
      assert_equal "The following records and revision id's have been added C1000000020-LANCEAMSR2 - 21 ", flash[:notice]
      collection = Collection.find_by concept_id: 'C1000000020-LANCEAMSR2'
      records = collection.records
      array = records.map(&:revision_id)
      assert_includes array, '21'
      Quarc.stub_any_instance(:validate, {}) do
        post :refresh
      end
      assert_equal 'No New Records Were Found', flash[:notice]
    end
  end

  describe 'post#hide' do
    it 'it deletes a single record' do
      @tester = User.find_by role: 'arc_curator'
      sign_in(@tester)
      stub_urs_access(@tester.uid, @tester.access_token, @tester.refresh_token)
      @request.env['HTTP_REFERER'] = 'http://foo.com'
      post :hide, params: { 'record_id': 1 }
      assert_equal 'Deleted the following collections: C1000000020-LANCEAMSR2/8 ', flash[:notice]
    end
    it 'it properly undeletes a single record' do
      user = User.find_by(role: 'admin')
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)
      @controller.stubs(:current_user).returns(users(:user1))
      @request.env['HTTP_REFERER'] = 'http://foo.com'

      assert_equal Record.find_by(id: 1).state, 'in_arc_review'
      post :hide, params: { 'record_id': 1 }
      assert_equal 'Deleted the following collections: C1000000020-LANCEAMSR2/8 ', flash[:notice]
      assert_equal Record.find_by(id: 1).state, 'hidden'
      post :unhide, params: { 'unhide_form_record_ids': '1', 'unhide_state': 'in_arc_review' }
      assert_equal Record.find_by(id: 1).state, 'in_arc_review'
      assert_equal 'Undeleted the following collections: C1000000020-LANCEAMSR2/8 ', flash[:notice]
    end
    it 'it deletes multiple records' do
      @tester = User.find_by role: 'arc_curator'
      sign_in(@tester)
      stub_urs_access(@tester.uid, @tester.access_token, @tester.refresh_token)
      @request.env['HTTP_REFERER'] = 'http://foo.com'
      post :hide, params: { 'record_id': [1,12]}
      assert_equal 'Deleted the following collections: C1000000020-LANCEAMSR2/8 C1000000020-LANCEAMSR2/9 ', flash[:notice]
    end

    it 'it properly undeletes multiple records' do
      @tester = User.find_by role: 'arc_curator'
      sign_in(@tester)
      stub_urs_access(@tester.uid, @tester.access_token, @tester.refresh_token)
      @request.env['HTTP_REFERER'] = 'http://foo.com'
      assert_equal Record.find_by(id: 12).state, 'in_daac_review'
      assert_equal Record.find_by(id: 14).state, 'in_daac_review'
      post :hide, params: { 'record_id': [12,14]}
      assert_equal 'Deleted the following collections: C1000000020-LANCEAMSR2/9 arc_curator_collection/7 ', flash[:notice]
      assert_equal Record.find_by(id: 12).state, 'hidden'
      assert_equal Record.find_by(id: 14).state, 'hidden'
      post :unhide, params: { 'unhide_form_record_ids': '12 14', 'unhide_state': 'in_daac_review' }
      assert_equal Record.find_by(id: 12).state, 'in_daac_review'
      assert_equal Record.find_by(id: 14).state, 'in_daac_review'
      assert_equal 'Undeleted the following collections: C1000000020-LANCEAMSR2/9 arc_curator_collection/7 ', flash[:notice]
    end

    it 'ensure associate granule record not hidden, see CMRARC-586' do
      user = User.find_by(role: 'admin')
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)
      record_rev_2 = Record.find(41)
      post :hide, params: { 'record_id': [41]}
      granule_record_id = record_rev_2.associated_granule_value
      granule_record = Record.find(granule_record_id)
      assert_equal granule_record.state, 'in_daac_review'
    end
  end

end

