require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class UpdateDiscussionTest < ActiveSupport::TestCase
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

  describe 'update discussion.' do
    it 'add discussion and then update, delete' do
      visit '/home'
      within '#open' do
        all('#record_id_')[0].click  # Selects the first checkbox in "unreviewed records"
        find('div > div.navigate-buttons > input.selectButton').click # Clicks the See Review Details button
      end
      within '#collection_revision_5' do
        click_on "See Collection Review Details"
      end
      click_on "Collection Info"
      within("#scroll_table > table > tbody > tr:nth-child(12) > td.discussion_td.column_ShortName > div > div") do
        fill_in 'discussion[ShortName]', with: 'short name review discussion'
      end
      click_on 'Save Review'
      assert has_content? 'short name review discussion'
      # update discussion
      within('.discussion_update_icons') do
        all('i')[0].click
      end
      within('.discussion_update_form') do
        fill_in 'discussion', with: 'short name review updated'
        click_on 'UPDATE'
      end
      assert has_content? 'short name review updated'
      # add another discussion
      within("#scroll_table > table > tbody > tr:nth-child(12) > td.discussion_td.column_ShortName > div > div.new_discussion") do
        fill_in 'discussion[ShortName]', with: 'second discussion'
      end
      click_on 'Save Review'
      assert has_content? 'second discussion'
      # remove second discussion
      within all('.discussion_update_icons')[0] do
        all('i')[1].click
      end
      accept_confirm_dialog
      assert has_no_content? 'second discussion'
    end
  end
end