require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class CanShowCollectionsTest < SystemTestCase
  include Helpers::UserHelpers
  include Helpers::CollectionsHelper
  include Helpers::HomeHelper

  describe 'Showing Closed Records' do

    describe 'when the user is a daac curator' do
      before do
        OmniAuth.config.test_mode = true
        mock_login(id: 5)
      end

      it 'can show closed records' do
        # view closed records tab
        visit '/records/finished'
        # Verify they can select the completed review and view it.
        see_collection_review_details('#finished', 15)
        # There are 2 records in review for this collection, 1 in process, 1 completed.
        # We should NOT show the in process review.
        assert has_no_content? 'Collection Review Status: In Process'
        # We SHOULD show the closed review.
        assert has_content? 'Collection Review Status: Closed'
        # We should be able to see the review details of the closed record.
        see_collection_revision_details(4)
        assert has_content? 'METADATA ELEMENTS'
      end
    end

  end
end
