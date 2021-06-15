require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class CanSearchVirtualProvidersTest < Capybara::Rails::TestCase
  include Helpers::UserHelpers
  include Helpers::ReviewsHelper
  include Helpers::HomeHelper
  include Helpers::CollectionsHelper

  before do
    OmniAuth.config.test_mode = true
    mock_login(role: 'admin')

    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC")
        .with(
            headers: {'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept' => '*/*', 'User-Agent' => 'Ruby'}
        )
        .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>0</hits><took>32</took></results>', headers: {})
    end

  describe "GET #search" do
    it "searches for collections under ASDC provider" do
      visit '/home'
      within '#provider' do
        find("#provider > option:nth-child(3)").click
      end
      # find("#search_button").click
      assert has_content?
      screenshot_and_open_image
    end

    it "searches for collections under NSIDC provider" do
      visit '/home'
      within '#provider' do
        find("#provider > option:nth-child(11)").click
      end
      # find("#search_button").click
      assert has_content?
      screenshot_and_open_image
    end

    it "searches for collections under GHRC provider" do
      visit '/home'
      within '#provider' do
        find("#provider > option:nth-child(6)").click
      end
      # find("#search_button").click
      assert has_content?
      screenshot_and_open_image
    end
  end
end