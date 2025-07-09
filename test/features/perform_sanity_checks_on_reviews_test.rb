require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class PerformsSanityChecksOnReviewsTest < SystemTestCase
  include Helpers::UserHelpers
  include Helpers::CollectionsHelper
  include Helpers::ReviewsHelper
  include Helpers::HomeHelper

  before do
    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC")
      .with(
        headers: {'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept' => '*/*'}
      )
      .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>0</hits><took>32</took></results>', headers: {})

    OmniAuth.config.test_mode = true
  end

  describe 'performs "mark complete" on a collection record and granule record' do
    before do
      mock_login(role: 'arc_curator')
      visit '/home'

      # link granule to collection for remaining tests
      assert_equal Record.find_by(id: 1).state, 'in_arc_review'

      see_collection_review_details('#in_arc_review', 1)
      associate_granule_to_collection(16, 8)
      assert_equal Record.find_by(id: 1).state, Record.find_by(id: 16).state

      # Since we are in "In Arc Review", user shouldn't get any errors even though the granule review isn't finished.
      assert has_content? 'Granule G309210-GHRC/6 has been successfully associated to this collection revision 8'

      # Now lets add a review comment
      see_collection_revision_details(8)
      assign_review_comments('my review comment', 'my report comment')

      # We should see some informative issues.  These won't prevent saving the review.
      assert has_content? 'Note, not all columns have been flagged with a color, be sure this is done before marking this review complete.'
      assert has_content? 'Note, some columns still need a second opinion review.'

      click_button 'MARK AS DONE'
    end

    describe 'on granule record' do

      # in this case short name, long name are marked with a color, but version id is not in the granule
      # lets fix the granule first
      it 'checks to see if it produces error' do
        # Now click MARK AS DONE
        assert_equal Record.find_by(id: 1).state, 'in_arc_review'
        assert_equal Record.find_by(id: 1).state, Record.find_by(id: 16).state

        # We should see errors and will prevent the collection from moving to ready for daac review.
        assert has_content?('Not all columns in the associated granule have been flagged with a color!')
        assert has_content?('The associated granule needs two completed reviews')
        assert has_content? 'Record failed to update.'
        assert_no_css '#done_button[disabled]' # still enabled

        describe 'granule is fixed' do
          before do
            # Lets back out to fix the granule issues.
            find('#nav_back_button').click

            see_granule_revision_details(6)
            assign_review_comments('my review comment', 'my report comment')

            # Now lets fix issue #1 and make sure the column has a flagged color
            click_button 'Collection Info'

            find('#color_button_green_ShortName').click
            find('.review-toggle__text').click
            #
            # Lets save the review and back out again.
            click_button 'Save Review'

            find('#nav_back_button').click
            find('#nav_back_button').click

            # Lets view the collection review details again
            see_collection_revision_details(8)

            # Now click mark as done should reveal a new error, this time with the collection.
            click_button 'MARK AS DONE'
          end

          it 'verifies only collection errors are left' do

            assert_equal Record.find_by(id: 1).state, 'in_arc_review'
            assert_equal Record.find_by(id: 1).state, Record.find_by(id: 16).state

            # only collection errors left
            assert has_no_content? 'Not all columns in the associated granule have been flagged with a color!'
            assert has_no_content? 'The associated granule needs two completed reviews'
            assert has_content? 'Not all columns have been flagged with a color, cannot close review.'
            assert has_content? 'Record failed to update.'

            describe 'on the collection' do
              before do
                # fixes collections
                see_collection_revision_details(8)
                click_button 'MARK AS DONE'
                click_button 'Collection Info'
                find('#color_button_green_VersionId').click
                click_button 'Save Review'
                find('#nav_back_button').click

                # produces success message
                click_button 'MARK AS DONE'
              end

              it 'fixes the collection and produces success message - should ignore second opinion checks' do
                assert_equal Record.find_by(id: 1).state, 'ready_for_daac_review'
                assert_equal Record.find_by(id: 1).state, Record.find_by(id: 16).state
                assert has_content? 'Record has been successfully updated.'
              end

              describe 'tries to release to daac' do
                before do
                  # Now lets try to release to daac, it should fail because collection should fail the second opinion check,
                  # which is only checked when being released to a daac
                  see_collection_revision_details(8)

                  # Now the button should say "RELEASE TO DAAC" since we are in ready_for_daac_review state
                  click_button 'RELEASE TO DAAC'
                end
                it 'releases to daac' do
                  assert has_content? 'Record failed to update.'
                  assert has_content? 'Some columns still need a second opinion review, cannot close review.'

                  # Lets fix this now
                  click_button 'Collection Info'
                  find('.review-toggle__text').click
                  click_button 'Save Review'
                  find('#nav_back_button').click

                  click_button 'RELEASE TO DAAC'
                  assert has_content? 'Record has been successfully updated.'
                  assert_equal Record.find_by(id: 1).state, 'in_daac_review'
                  assert_equal Record.find_by(id: 1).state, Record.find_by(id: 16).state
                end
              end
            end
          end
        end
      end
    end
  end

  describe 'viewing the granule review, the buttons "Mark Complete","Release to DAAC", "CMR Updated" etc. are no longer present.' do
    before do
      mock_login(role: 'arc_curator')
      visit '/home'
    end

    it 'verify correct buttons appear' do
      # Select First Collection in In Arc Review
      see_collection_review_details('#in_arc_review', 1)
      see_granule_revision_details(6)
      assert_css '#review_complete_button'
      assert_no_css '#done_button'
    end
  end

  describe 'viewing the Collection Info, only one VersionDescription column is present.' do
    before do
      mock_login(role: 'arc_curator')
      visit '/home'
    end

    it 'verify only one VersionDescription appears' do
      # Select First Collection in In Arc Review
      see_collection_review_details('#in_arc_review', 1)
      see_collection_revision_details(8)
      click_button 'MARK AS DONE'
      click_button 'Collection Info'
      expect(page).to have_content("VersionDescription", count: 2)
    end
  end
end




