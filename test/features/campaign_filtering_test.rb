require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class CanShowCollectionsTest < SystemTestCase
  include Helpers::UserHelpers

  before do
    OmniAuth.config.test_mode = true
  end

  describe 'Campaign Filtering' do
    describe 'when the user is an Arc Curator' do
      before do
        mock_login(id: 3) # arc curator
        visit home_path
      end

      it 'has the expected campaigns in the filter box' do
        # Capybara does not have a "without_options:" kind of filter.
        assert has_no_select?('campaign', with_options: ['TESTCAMP1'])
        assert has_no_select?('campaign', with_options: ['TESTCAMP2'])
        assert has_no_select?('campaign', with_options: ['TESTCAMP5'])
        assert has_no_select?('campaign', with_options: ['TESTCAMP6'])
        assert has_select?('campaign', with_options: ['CAMPAIGN/PROJECT: ANY', 'TESTCAMP3', 'TESTCAMP4'])
      end

      it 'can see unfiltered records' do
        assert has_content?('campaign_test_collection_1-PODAAC')
        assert has_content?('campaign_test_collection_2-PODAAC')
        assert has_content?('campaign_test_collection_3-OB_DAAC')
        assert has_no_content?('campaign_test_collection_4-JAXA')
        assert has_no_content?('campaign_test_collection_5-SCIOPS')
        assert has_no_content?('campaign_test_collection_6-JAXA')
      end

      describe 'when the user filters some records' do
        before do
          select 'TESTCAMP3', from: 'campaign'
          click_on 'Filter'
        end

        it 'can see filtered records' do
          assert has_content?('campaign_test_collection_1-PODAAC')
          assert has_no_content?('campaign_test_collection_2-PODAAC')
          assert has_content?('campaign_test_collection_3-OB_DAAC')
          assert has_no_content?('campaign_test_collection_4-JAXA')
          assert has_no_content?('campaign_test_collection_5-SCIOPS')
          assert has_no_content?('campaign_test_collection_6-JAXA')
        end

        describe 'when the user removes the filter' do
          before do
            select 'CAMPAIGN/PROJECT: ANY', from: 'campaign'
            click_on 'Filter'
          end

          it 'can see unfiltered records' do
            assert has_content?('campaign_test_collection_1-PODAAC')
            assert has_content?('campaign_test_collection_2-PODAAC')
            assert has_content?('campaign_test_collection_3-OB_DAAC')
          end
        end
      end
    end

    describe 'when the user is an MDQ Curator' do
      before do
        mock_login(id: 11) # mdq curator
        visit home_path
      end

      it 'has the expected campaigns in the filter box' do
        # Capybara does not have a "without_options:" kind of filter.
        assert has_no_select?('campaign', with_options: ['TESTCAMP1'])
        assert has_no_select?('campaign', with_options: ['TESTCAMP2'])
        assert has_no_select?('campaign', with_options: ['TESTCAMP3'])
        assert has_no_select?('campaign', with_options: ['TESTCAMP4'])
        assert has_select?('campaign', with_options: ['CAMPAIGN/PROJECT: ANY', 'TESTCAMP5', 'TESTCAMP6'])
      end

      it 'can see unfiltered records' do
        assert has_no_content?('campaign_test_collection_1-PODAAC')
        assert has_no_content?('campaign_test_collection_2-PODAAC')
        assert has_no_content?('campaign_test_collection_3-OB_DAAC')
        assert has_content?('campaign_test_collection_4-JAXA')
        assert has_content?('campaign_test_collection_5-SCIOPS')
        assert has_content?('campaign_test_collection_6-JAXA')
      end

      describe 'when the user filters some records' do
        before do
          select 'TESTCAMP5', from: 'campaign'
          click_on 'Filter'
        end

        it 'can see filtered records' do
          assert has_no_content?('campaign_test_collection_1-PODAAC')
          assert has_no_content?('campaign_test_collection_2-PODAAC')
          assert has_no_content?('campaign_test_collection_3-OB_DAAC')
          assert has_content?('campaign_test_collection_4-JAXA')
          assert has_no_content?('campaign_test_collection_5-SCIOPS')
          assert has_content?('campaign_test_collection_6-JAXA')
        end

        describe 'when the user removes the filter' do
          before do
            select 'CAMPAIGN/PROJECT: ANY', from: 'campaign'
            click_on 'Filter'
          end

          it 'can see unfiltered records' do
            # CG assert has_content?('campaign_test_collection_4-JAXA')
            # CG assert has_content?('campaign_test_collection_5-SCIOPS')
            # CG assert has_content?('campaign_test_collection_6-JAXA')
          end
        end
      end
    end

    describe 'when the user is a daac Curator, part 1' do
      before do
        mock_login(id: 5) # podaac curator
        visit home_path
      end

      it 'has the expected campaigns in the filter box' do
        assert has_no_select?('campaign', with_options: ['TESTCAMP3'])
        assert has_no_select?('campaign', with_options: ['TESTCAMP4'])
        assert has_no_select?('campaign', with_options: ['TESTCAMP5'])
        assert has_no_select?('campaign', with_options: ['TESTCAMP6'])
        assert has_select?('campaign', with_options: ['CAMPAIGN/PROJECT: ANY', 'TESTCAMP1', 'TESTCAMP2'])
      end

      it 'can see unfiltered records' do
        assert has_content?('campaign_test_collection_1-PODAAC')
        assert has_content?('campaign_test_collection_2-PODAAC')
        assert has_no_content?('campaign_test_collection_3-OB_DAAC')
      end

      describe 'when the user filters some records' do
        before do
          select 'TESTCAMP1', from: 'campaign'
          click_on 'Filter'
        end

        it 'can see filtered records' do
          assert has_content?('campaign_test_collection_1-PODAAC')
          assert has_no_content?('campaign_test_collection_2-PODAAC')
          assert has_no_content?('campaign_test_collection_3-OB_DAAC')
        end

        describe 'when the user removes the filter' do
          before do
            select 'CAMPAIGN/PROJECT: ANY', from: 'campaign'
            click_on 'Filter'
          end

          it 'can see unfiltered records' do
            assert has_content?('campaign_test_collection_1-PODAAC')
            assert has_content?('campaign_test_collection_2-PODAAC')
            assert has_no_content?('campaign_test_collection_3-OB_DAAC')
          end
        end
      end
    end
  end

  describe 'when the user is a daac Curator, part 2' do
    before do
      mock_login(id: 10) # ob_daac curator
      visit home_path
    end

    it 'has the expected campaigns in the filter box' do
      assert has_no_select?('campaign', with_options: ['TESTCAMP2'])
      assert has_no_select?('campaign', with_options: ['TESTCAMP3'])
      assert has_no_select?('campaign', with_options: ['TESTCAMP4'])
      assert has_no_select?('campaign', with_options: ['TESTCAMP5'])
      assert has_no_select?('campaign', with_options: ['TESTCAMP6'])
      assert has_select?('campaign', with_options: ['CAMPAIGN/PROJECT: ANY', 'TESTCAMP1'])
    end

    it 'can see unfiltered records' do
      assert has_no_content?('campaign_test_collection_1-PODAAC')
      assert has_no_content?('campaign_test_collection_2-PODAAC')
      assert has_content?('campaign_test_collection_3-OB_DAAC')
    end

    describe 'when the user filters some records' do
      before do
        select 'TESTCAMP1', from: 'campaign'
        click_on 'Filter'
      end

      it 'can see filtered records' do
        assert has_no_content?('campaign_test_collection_1-PODAAC')
        assert has_no_content?('campaign_test_collection_2-PODAAC')
        assert has_content?('campaign_test_collection_3-OB_DAAC')
      end

      describe 'when the user removes the filter' do
        before do
          select 'CAMPAIGN/PROJECT: ANY', from: 'campaign'
          click_on 'Filter'
        end

        it 'can see unfiltered records' do
          assert has_no_content?('campaign_test_collection_1-PODAAC')
          assert has_no_content?('campaign_test_collection_2-PODAAC')
          assert has_content?('campaign_test_collection_3-OB_DAAC')
        end
      end
    end
  end
end