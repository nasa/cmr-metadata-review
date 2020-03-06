require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each {|f| require f}

class MdqCuratorTest < Capybara::Rails::TestCase
  include Helpers::UserHelpers

  before do
    OmniAuth.config.test_mode = true
  end

  # turning on the feature toggle will filter records based on the provider list associated with the application mode.
  # The application mode is determined by the logged in user's role.   If they are a "mdq_curator" the mode will be :mdq_mode.
  # If they are an arc_curator, admin, the application_mode will be :arc_mode.   The mode will causing the filtering of
  # collections, granules based on a specific provider list.   This could affect performance and why we have made this a
  # feature toggle.
  describe 'mdq_enabled feature toggle - true' do
    before do
      Rails.configuration.mdq_enabled_feature_toggle = true
    end

    describe 'Access to mdq records' do
      before do
        mock_login(role: "mdq_curator") # mdq curator
      end

      it 'can see the mdq records' do
        visit home_path
        within '#in_arc_review' do
          assert has_no_content? 'arc_curator_collection'
          assert has_content? 'mdq_curator_collection'
        end
      end
    end

    describe 'Access to arc records' do
      before do
        mock_login(role: "arc_curator") # arc curator
      end

      it 'can see the arc records' do
        visit home_path
        within '#in_arc_review' do
          assert has_content? 'arc_curator_collection'
          assert has_no_content? 'mdq_curator_collection'
        end
      end
    end

    describe 'Access to daac records in mdq_mode' do
      before do
        mock_login(id: 12) # daac curator, but mdq one
      end

      it 'can see the mdq records in daac review section' do
        visit home_path
        within '#in_daac_review' do
          assert has_content? 'mdq_curator_collection'
          assert has_no_content? 'arc_curator_collection'
          screenshot_and_open_image
        end
      end
    end

    describe 'Access to daac records in arc_mode' do
      before do
        mock_login(role: "admin") # admin is considered in the :arc_mode
      end

      it 'can see the arc records in daac review section' do
        visit home_path
        within '#in_daac_review' do
          assert has_content? 'arc_curator_collection'
          assert has_no_content? 'mdq_curator_collection'
        end
      end
    end

  end

  # turning off the feature toggle will show ALL records.  This will be the state for production to assure no
  # performance penalty until we can fully verify performance is not an issue with the new filtering of records.
  describe 'mdq_enabled feature toggle - false' do
    before do
      Rails.configuration.mdq_enabled_feature_toggle = false
    end

    describe 'Access to mdq records' do
      before do
        mock_login(role: "mdq_curator") # mdq curator
      end

      it 'can see the mdq records and arc records' do
        visit home_path
        within '#in_arc_review' do
          assert has_content? 'arc_curator_collection'
          assert has_content? 'mdq_curator_collection'
        end
      end
    end
  end

end
