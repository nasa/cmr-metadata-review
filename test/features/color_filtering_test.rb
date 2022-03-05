require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class CanShowCollectionsTest < SystemTestCase
  include Helpers::UserHelpers

  before do
    OmniAuth.config.test_mode = true
  end

  describe 'Color Filtering' do
    describe 'when the user is admin' do
      before do
        mock_login(role: "admin") # admin
        visit home_path
      end

      it 'can see un-filtered records' do
        assert has_content?('C1000000020-LANCEAMSR2')
        assert has_content?('campaign_test_collection_1-PODAAC')
      end

      describe 'when the user filters some records by collection' do
        before do
          select 'Red (Error)', from: 'color_code'
          click_on 'Filter'
        end
        it 'can see filtered records' do
          assert has_content?('C1000000020-LANCEAMSR2')
          assert has_no_content?('campaign_test_collection_1-PODAAC')
        end
      end

      describe 'when the user filters some records by granule' do
        before do
          select 'Red (Error)', from: 'color_code'
          check 'color_code_filter_granule'
          uncheck 'color_code_filter_collection'
          click_on 'Filter'

        end
        it 'can see filtered records' do
          assert has_content?('metric3-PODAAC')
          assert has_no_content?('campaign_test_collection_1-PODAAC')
        end
      end

      describe 'when the user filters some records by collection and granule' do
        before do
          select 'Red (Error)', from: 'color_code'
          check 'color_code_filter_granule'
          click_on 'Filter'

        end
        it 'can see filtered records' do
          assert has_content?('C1000000020-LANCEAMSR2')
          assert has_content?('metric3-PODAAC')
          assert has_no_content?('campaign_test_collection_1-PODAAC')
        end
      end
    end
  end
end
