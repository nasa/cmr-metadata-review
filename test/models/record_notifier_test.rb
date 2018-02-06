require 'test_helper'

class RecordNotifierTest < ActiveSupport::TestCase

  describe "notify_daac_curators" do

    it 'should email daac curators by daac' do
      records = Record.find([12, 14])

      assert_difference 'ActionMailer::Base.deliveries.size', +2 do
        RecordNotifier.notify_daac_curators(records)
      end
    end

  end

end