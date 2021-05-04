require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class UpdateReviewCommentTest < ActiveSupport::TestCase
  include Helpers::UserHelpers
  include Helpers::ReviewsHelper

  before do
    OmniAuth.config.test_mode = true
    mock_login(role: 'arc_curator')

    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC")
        .with(
            headers: {'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept' => '*/*', 'User-Agent' => 'Ruby'}
        )
        .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>0</hits><took>32</took></results>', headers: {})
  end

  describe 'update review comment.' do
    it 'add review comments and then update, delete' do
      visit '/home'
      within '#open' do
        all('#record_id_')[0].click  # Selects the first checkbox in "unreviewed records"
        find('div > div.navigate-buttons > input.selectButton').click # Clicks the See Review Details button
      end
      within '#collection_revision_5' do
        click_on "See Collection Review Details"
      end
      fill_in 'review_review_comment', with: 'a new review comment'
      fill_in 'review_report_comment', with: 'a report comment'
      click_on 'REVIEW COMPLETE'
      # clicks on edit icon to update the review comment
      within('.comment_review_update_icons') do
        all('i')[0].click
      end
      within('.comment_review_update_form') do
        fill_in 'review_comment', with: 'an updated review comment'
        click_on 'UPDATE'
      end
      assert has_content? 'an updated review comment'
      # clicks on edit icon to update the report comment
      within('.comment_report_update_icons') do
        all('i')[0].click
      end
      within('.comment_report_update_form') do
        fill_in 'report_comment', with: 'an updated report comment'
        click_on 'UPDATE'
      end
      assert has_content? 'an updated report comment'
      # # removes the review comment
      # within('.comment_review_update_icons') do
      #   all('i')[1].click
      # end
      # accept_confirm_dialog
      # assert has_no_content? 'an updated review comment'
      # # removes the report comment
      # within('.comment_report_update_icons') do
      #   all('i')[1].click
      # end
      # accept_confirm_dialog
      # assert has_no_content? 'an updated report comment'
    end
  end
end