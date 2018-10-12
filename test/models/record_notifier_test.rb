require 'test_helper'

class RecordNotifierTest < ActiveSupport::TestCase

  describe "notify_released" do

    it 'should email daac curators for released records' do
      # records = Record.find([12, 14]).to_a
      #
      # assert_difference 'ActionMailer::Base.deliveries.size', +2 do
      #   RecordNotifier.notify_released(records)
      # end
    end

  end

  describe "notify_closed" do

    it 'should email daac curators for closed records' do
      # records = Record.find([15]).to_a
      #
      # assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      #   RecordNotifier.notify_closed(records)
      # end
    end

  end

end