require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class UpdateReviewCommentTest < SystemTestCase
  include Helpers::UserHelpers
  include Helpers::ReviewsHelper
  include Helpers::CollectionsHelper
  include Helpers::HomeHelper

  before do
    OmniAuth.config.test_mode = true
    mock_login(role: 'arc_curator')
  end

  describe 'Show ingested iso record.' do
    it 'Navigate to show iso mends field mapping' do
      visit '/home'
      see_collection_review_details('#in_arc_review', 42)
      see_collection_revision_details(1)
      click_on 'Collection Info'
      page.driver.browser.action.move_to(page.find('#ShortName').native).perform
      page.has_content? "/gco:CharacterString = gov.nasa.esdis.umm.shortname"
    end
    it 'Navigate to show iso smap field mapping' do
      visit '/home'
      see_collection_review_details('#in_arc_review', 43)
      see_collection_revision_details(1)
      click_on 'Collection Info'
      page.driver.browser.action.move_to(page.find('#ShortName').native).perform
      page.has_content? "/gco:CharacterString = The ECS Short Name"
    end
  end
end
