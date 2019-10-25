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

    describe 'copies all recommendations it can.' do

      # the fixtures have 2 column name/values that are the same, 1 column name that is different.
      it 'finds 2 recommendations it can copy, 1 it can not.' do
        visit '/home'

        within '#open' do
          all('#record_id_')[0].click  # Selects the first checkbox in "unreviewed records"
          find('div > div.navigate-buttons > input.selectButton').click # Clicks the See Review Details button
        end

        within '#collection_revision_5' do
          accept_alert do
            click_on "Copy Prior Recommendations"
          end
        end
        page.must_have_content('Successfully copied 2/3 recommendations')
      end

      # revision 4 is the first revision, so we shouldn't see a copy prior recommendations link.
      it 'doesnt include copy prior recommendations link if there is no prior record' do
        visit '/home'

        within '#open' do
          all('#record_id_')[0].click  # Selects the first checkbox in "unreviewed records"
          find('div > div.navigate-buttons > input.selectButton').click # Clicks the See Review Details button
        end
        within '#collection_revision_4' do
          page.wont_have_content("Copy Prior Recommendations")
        end
      end

    end

end