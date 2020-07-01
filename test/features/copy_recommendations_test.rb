require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each {|f| require f}

class CopyRecommendationsTest < Capybara::Rails::TestCase
    include Helpers::UserHelpers

    before do
      OmniAuth.config.test_mode = true
      mock_login(role: 'arc_curator')

      stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC")
        .with(
          headers: {'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept' => '*/*', 'User-Agent' => 'Ruby'}
        )
        .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>0</hits><took>32</took></results>', headers: {})
    end

    describe 'copying recommendations.' do
      # this use case has a prior revision, so the button should be active and when we click it,
      # we will get a message that we successfully copied recommendations.
      it 'copies recommendations from a prior revision.' do
        visit '/home'

        within '#open' do
          all('#record_id_')[0].click  # Selects the first checkbox in "unreviewed records"
          find('div > div.navigate-buttons > input.selectButton').click # Clicks the See Review Details button
        end
        within '#collection_revision_5' do
          click_on "See Collection Review Details"
        end
        click_on "Copy Prior Recommendations"
        click_on "Copy Recommendations"
        page.must_have_content('Successfully copied recommendations')
      end

      # this use case will copy recommendations from a prior revision but if we try it again, it will verify
      # the button is disabled so we can't perform the action again.
      it 'prevents user from pressing the copy recommendations button twice.' do
        visit '/home'

        within '#open' do
          all('#record_id_')[0].click  # Selects the first checkbox in "unreviewed records"
          find('div > div.navigate-buttons > input.selectButton').click # Clicks the See Review Details button
        end
        within '#collection_revision_5' do
          click_on "See Collection Review Details"
        end
        click_on "Copy Prior Recommendations"
        click_on "Copy Recommendations"
        assert has_css?("input[class='eui-btn--disabled'][value='Copy Prior Recommendations']")
      end


      # this verifies the revision id text field is empty if there is no prior revision.
      it 'verifies the revision id text field is empty if there is no prior revision' do
        visit '/home'

        within '#open' do
          all('#record_id_')[0].click  # Selects the first checkbox in "unreviewed records"
          find('div > div.navigate-buttons > input.selectButton').click # Clicks the See Review Details button
        end
        within '#collection_revision_4' do
          click_on "See Collection Review Details"
        end
        assert has_css? "input[value='Copy Prior Recommendations']"
        click_on "Copy Prior Recommendations"
        assert has_css?("input[type='text'][name='concept_id'][value='C1000000020-LANCEAMSR2']")
        assert has_css?("input[type='text'][name='revision_id'][value='']")
      end

    end

end