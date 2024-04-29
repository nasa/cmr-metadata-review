require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each {|f| require f}

class CuratorFeedbackTest < SystemTestCase
  include Helpers::UserHelpers

  before do
    OmniAuth.config.test_mode = true
    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC")
      .with(
        headers: { 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept' => '*/*' }
      )
      .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>0</hits><took>32</took></results>', headers: {})
  end

  # This is the base case there are no feedback records, so this:
  # 1) Verifies there are no feedback records
  # 2) Verifies only daac curators can click the curator feedback button
  context 'Curator Feedback with no feedback fields' do
    should 'verifies no records in Requires Reviewer Feedback Records section.' do
      mock_login(id: 5) # daac curator
      visit '/home'
      within '#provide_feedback' do
        assert has_no_content?('C1000000020-LANCEAMSR2')
      end
    end

    should 'only daac curators can click the curator feedback button' do
      mock_login(role: "admin") # admin

      visit '/home'
      within '#in_daac_review' do
        all('#record_id_')[0].click
        within '.navigate-buttons' do
          click_on 'See Review Detail'
        end
      end
      within '#collection_revision_9' do
        click_on 'See Collection Review Details'
      end

      within '.record_review_data' do
        click_on 'Collection Info'
      end
      first('#feedback_text_ShortName').click
      within '#feedback_text_ShortName' do
        refute has_css?(".eui-check-o")
      end

    end
  end

  # These is the second set of tests, where we include a feedback record.
  # It performs the following tests:
  # 1) Initial setup of the feedback record as a daac curator
  # 2) Verifies the record shows up in the required curator feedback section for daac curators
  # 3) Verifies the record shows up in the required curator feedback section for arc curators
  # 4) Verifies the record disappears once the record is closed.
  context 'Curator Feedback with a field requesting feedback' do
    before do
      mock_login(id: 5) # daac curator
      visit '/home'
      within '#in_daac_review' do
        all('#record_id_')[0].click
        within '.navigate-buttons' do
          click_on 'See Review Detail'
        end
      end
      within '#collection_revision_9' do
        click_on 'See Collection Review Details'
      end

      within '.record_review_data' do
        click_on 'Collection Info'
      end
      first('#feedback_text_ShortName').click

      fill_in('feedback_discussion[ShortName]', with: 'please double check')
      click_on 'Save Review'

      within '#feedback_text_ShortName' do
        assert has_css?(".eui-check-o")
      end
    end

    should 'verifies the record shows up in Requires Reviewer Feedback Records section for the daac curator.' do
      mock_login(id: 5) # daac curator
      visit '/home'
      within '#provide_feedback' do
        assert has_content?('C1000000020-LANCEAMSR2')
      end
    end

    should 'curator feedback shows up for arc curator' do
      mock_login(id: 3) # arc curator
      visit '/home'
      within '#provide_feedback' do
        assert has_content?('C1000000020-LANCEAMSR2')
      end
    end

  end


end


