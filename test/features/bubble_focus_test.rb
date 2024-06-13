require 'test_helper'
require 'capybara/rails'
require 'capybara/minitest'
Dir[Rails.root.join('test/**/*.rb')].each {|f| require f}

class BubbleFocusTest < SystemTestCase
    include Helpers::UserHelpers

    before do
      OmniAuth.config.test_mode = true
      mock_login(role: 'arc_curator')

      stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC")
        .with(
          headers: {'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept' => '*/*'}
        )
        .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>0</hits><took>32</took></results>', headers: {})
    end

    describe 'bubble focus' do
      # this test will mock a user click on a bubble and then navigate to the correct
      # sub-section it indicates in the review table.
      it 'navigates to the indicated sub-section.' do
        visit '/home'

        within '#open' do
          all('#record_id_')[0].click  # Selects the first checkbox in "unreviewed records"
          find('div > div.navigate-buttons > input.selectButton').click # Clicks the See Review Details button
        end
        within '#collection_revision_5' do
          click_on "See Collection Review Details"
        end
        within "#record_bubbles" do
          find('#single_bubble_container_LongName button').click 
        end
        within "#review_table" do
          assert_selector('#column_LongName.highlighted')
          assert_selector('td.color_code_cell.column_LongName.color_green')
        end
        within "#bubble_title" do
          find('#bubble_ShortName', wait: 10).click
        end
        within "#review_table" do
          assert_selector('#column_ShortName.highlighted')
        end
      end
    end
  end