require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class CanShowCollectionsTest < SystemTestCase
  include Helpers::UserHelpers
  include Helpers::CollectionsHelper
  include Helpers::HomeHelper

  # describe 'Showing Closed Records' do
  #
  #   describe 'when the user is a daac curator' do
  setup do
        OmniAuth.config.test_mode = true
        mock_login(id: 5)
      end

  test 'can show closed records' do
        # view closed records tab
        visit '/records/finished'
        # save_and_open_page
        # screenshot_and_open_image
        # Verify they can select the completed review and view it.
        see_collection_review_details('#finished', 15)
        # There are 5 revisions for this collection, but only one that is closed
        page.must_have_button('See Collection Review Details', maximum: 1)
        # We should be able to see the review details of the closed record.
        see_collection_revision_details(4)
        assert has_content? 'METADATA ELEMENTS'
      end
    # end

  # end
end
