require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class CanShowCollectionsTest < Capybara::Rails::TestCase
  include Helpers::UserHelpers

  describe 'Showing Collections' do
    before do
      OmniAuth.config.test_mode = true
      mock_login(role: 'arc_curator')

      stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC")
        .with(
          headers: { 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept' => '*/*', 'User-Agent' => 'Ruby' }
        )
        .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>0</hits><took>32</took></results>', headers: {})
    end

    describe 'showing collection'  do
      it 'can see link for editing mmt' do
        visit '/home'

        # checks the check box next to the first collection record in the table
        check 'record_id_'

        # clicks the button, "see review details"
        find('#open > div > div.navigate_buttons > input').click

        # Tests to see if the edit collection in mmt link is there.
        page.must_have_link('EDIT COLLECTION IN MMT')
      end
    end
  end
end
