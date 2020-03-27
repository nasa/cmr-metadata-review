require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class PerformsSanityChecksOnReviewsTest < Capybara::Rails::TestCase
  include Helpers::UserHelpers

  before do
    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC")
      .with(
        headers: {'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept' => '*/*', 'User-Agent' => 'Ruby'}
      )
      .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>0</hits><took>32</took></results>', headers: {})
  end

  describe 'performs "mark complete" on a collection record' do
    before do
      OmniAuth.config.test_mode = true
      mock_login(role: 'arc_curator')
    end

    # in this case short name, long name are marked with a color, but version id is not
    it 'will perform sanity checks on BOTH collection and assoc granule review' do
      visit '/home'

      assert_equal Record.find_by(id: 1).state, 'in_arc_review'

      # Select First Collection in In Arc Review
      within '#in_arc_review' do
        all('#record_id_')[0].click  # Selects the checkbox in "in arc review"
        find('div > div.navigate-buttons > input.selectButton').click # Clicks the See Review Details button
      end

      # Associate Granule Revision 6 with Collection Revision #8
      within '#collection_revision_8' do
        within '#form-8' do
          first('#associated_granule_value').find("option[value='Undefined']").click # other tests are not cleaning up db, so reset it back manually
          first('#associated_granule_value').find("option[value='16']").click # Click in select box for what granule to associate
        end
      end
      assert_equal Record.find_by(id: 1).state, Record.find_by(id: 16).state

      # Since we are in "In Arc Review", user shouldn't get any errors even though the granule review isn't finished.
      assert has_content? 'Granule G309210-GHRC/6 has been successfully associated to this collection revision 8'

      # Now lets add a review comment
      within '#collection_revision_8' do
        find('table > tbody > tr:nth-child(2) > td > div > form > input').click # click See Collection Review Details
      end

      # Set the review comment
      within '.review_comments' do
        review_comment = find('#review_review_comment')
        review_comment.set('my review comment')
        report_comment = find('#review_report_comment')
        report_comment.set('my report comment')
      end

      # Click the button Review Complete
      assert_no_css '#review_complete_button[disabled]'
      find('#review_complete_button').click
      assert_css '#review_complete_button[disabled]'

      # We should see some informative issues.  These won't prevent saving the review.
      assert has_content? 'Note, not all columns have been flagged with a color, be sure this is done before marking this review complete.'
      assert has_content? 'Note, some columns still need a second opinion review.'

      # Now click MARK AS DONE
      click_button 'MARK AS DONE'
      assert_equal Record.find_by(id: 1).state, 'in_arc_review'
      assert_equal Record.find_by(id: 1).state, Record.find_by(id: 16).state

      # We should see errors and will prevent the collection from moving to ready for daac review.
      assert has_content?('Not all columns in the associated granule have been flagged with a color!')
      assert has_content?('The associated granule needs two completed reviews')
      assert has_content? 'Record failed to update.'
      assert_no_css '#done_button[disabled]' # still enabled

      # Lets back out to fix the granule issues.
      find('#nav_back_button').click

      # Click button to see Granule Review Details
      within '#granule_revision_6' do
        find('#granule_review_link > form > input').click
      end

      # Lets add our review to fix issue #2 in the errors listed.
      within '.review_comments' do
        review_comment = find('#review_review_comment')
        review_comment.set('my review comment')
        report_comment = find('#review_report_comment')
        report_comment.set('my report comment')
      end
      find('#review_complete_button').click

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
      within '#collection_revision_8' do
        find('table > tbody > tr:nth-child(2) > td > div > form > input').click # click See Collection Review Details
      end

      # Now click mark as done should reveal a new error, this time with the collection.
      click_button 'MARK AS DONE'

      assert_equal Record.find_by(id: 1).state, 'in_arc_review'
      assert_equal Record.find_by(id: 1).state, Record.find_by(id: 16).state

      assert has_no_content? 'Not all columns in the associated granule have been flagged with a color!'
      assert has_no_content? 'The associated granule needs two completed reviews'
      assert has_content? 'Not all columns have been flagged with a color, cannot close review.'
      assert has_content? 'Record failed to update.'

      # lets fix the collection issue
      click_button 'Collection Info'
      find('#color_button_green_VersionId').click
      click_button 'Save Review'
      find('#nav_back_button').click

      # Now we should succesfully mark the record done and it will move to ready for daac review.
      click_button 'MARK AS DONE'
      assert_equal Record.find_by(id: 1).state, 'ready_for_daac_review'
      assert_equal Record.find_by(id: 1).state, Record.find_by(id: 16).state

      assert has_content? 'Record has been successfully updated.'

      # Now lets try to release to daac, it should fail because collection should fail the second opinion check,
      # which is only checked when being released to a daac
      #

      within '#collection_revision_8' do
        find('table > tbody > tr:nth-child(2) > td > div > form > input').click # click See Collection Review Details
      end

      # Now the button should say "RELEASE TO DAAC" since we are in ready_for_daac_review state
      click_button 'RELEASE TO DAAC'

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

  describe 'viewing the granule review, the buttons "Mark Complete","Release to DAAC", "CMR Updated" etc. are no longer present.' do
    before do
      OmniAuth.config.test_mode = true
      mock_login(role: 'arc_curator')
    end

    it 'verify correct buttons appear' do

      visit '/home'

      # Select First Collection in In Arc Review
      within '#in_arc_review' do
        all('#record_id_')[0].click  # Selects the checkbox in "in arc review"
        find('div > div.navigate-buttons > input.selectButton').click # Clicks the See Review Details button
      end

      # Click button to see Granule Review Details
      within '#granule_revision_6' do
        find('#granule_review_link > form > input').click
      end

      assert_css '#review_complete_button'
      assert_no_css '#done_button'

    end
  end
end




