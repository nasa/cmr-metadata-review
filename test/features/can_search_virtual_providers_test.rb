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
  end

  describe "GET #search" do
    # it "searches for collections under ASDC provider" do
    #   stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/collections.echo10?keyword=**&page_num=1&page_size=10&provider=LARC")
    #     .with(
    #       headers: {'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept' => '*/*', 'User-Agent' => 'Ruby'}
    #     )
    #     .to_return(status: 200, body: get_stub("search_collections_echo10_providerLARC.xml"), headers: {'content-type': 'application/echo10+xml; charset=utf-8'})
    #
    #   visit '/home'
    #   within '#provider' do
    #     find("#provider > option:nth-child(3)").click
    #   end
    #   find("#search_button").click
    #   # sleep 1
    #   page.must_have_content('Search the CMR:')
    #   screenshot_and_open_image
    # end

    it "searches for collections under NSIDC provider" do
      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/collections.echo10?keyword=**&page_num=1&page_size=10&provider=NSIDC_ECS")
        .with(
          headers: {'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept' => '*/*', 'User-Agent' => 'Ruby'}
        )
        .to_return(status: 200, body: get_stub("search_collections_echo10_providerNSIDC_ECS.xml"), headers: {'content-type': 'application/echo10+xml; charset=utf-8'})

      visit '/home'
      within '#provider' do
        find("#provider > option:nth-child(11)").click
      end
      find("#search_button").click
      page.must_have_content('Search the CMR:')
      screenshot_and_open_image
    end
    #
    # it "searches for collections under GHRC provider" do
    #   visit '/home'
    #   within '#provider' do
    #     find("#provider > option:nth-child(6)").click
    #   end
    #   # find("#search_button").click
    #   assert has_content?
    #   screenshot_and_open_image
    # end
  end
end