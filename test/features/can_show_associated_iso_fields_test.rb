require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class UpdateReviewCommentTest < Capybara::Rails::TestCase
  include Helpers::UserHelpers
  include Helpers::ReviewsHelper
  include Helpers::CollectionsHelper
  include Helpers::HomeHelper

  before do
    OmniAuth.config.test_mode = true
    mock_login(role: 'arc_curator')
  end

  describe 'Show ingested iso record.' do
    it 'Navigate to show iso field mapping' do
      visit '/home'
      see_collection_review_details('#in_arc_review', 42)
      see_collection_revision_details(1)
      click_on 'Collection Info'
      assert has_content? "/gco:CharacterString= gov.nasa.esdis.umm.shortname"
      assert has_content? "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:defaultLocale/lan:PT_Locale/lan:language/lan:LanguageCode"
    end
  end
end