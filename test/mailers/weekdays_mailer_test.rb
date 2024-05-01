require 'test_helper'
require "#{Rails.root}/lib/rake_helpers/daac_curator_mailer_helper"

class WeekdaysMailerTest < ActionMailer::TestCase
  # context 'when users with different preferences are processed' do
  setup do
      @email_count = ActionMailer::Base.deliveries.count
    end

  test 'sends one email to one recipient on a Tuesday' do
      DaacCuratorMailerOrchestration.released_records_digest_conductor(now: Time.new(2020, 2, 4))

      assert_equal @email_count + 1, ActionMailer::Base.deliveries.count
      assert_equal [User.find(7).email], ActionMailer::Base.deliveries[@email_count].to
    end

  test 'sends one email to four recipients on the first Monday' do
      DaacCuratorMailerOrchestration.released_records_digest_conductor(now: Time.new(2020, 2, 3))

      assert_equal @email_count + 1, ActionMailer::Base.deliveries.count
      assert_equal [User.find(7).email, User.find(8).email, User.find(9).email, User.find(10).email], ActionMailer::Base.deliveries[@email_count].to
    end

  test 'sends one email to two recipients on the second Monday' do
      DaacCuratorMailerOrchestration.released_records_digest_conductor(now: Time.new(2020, 2, 10))

      assert_equal @email_count + 1, ActionMailer::Base.deliveries.count
      assert_equal [User.find(7).email, User.find(8).email], ActionMailer::Base.deliveries[@email_count].to
    end

  test 'sends one email to three recipients on the third Monday' do
      DaacCuratorMailerOrchestration.released_records_digest_conductor(now: Time.new(2020, 2, 17))

      assert_equal @email_count + 1, ActionMailer::Base.deliveries.count
      assert_equal [User.find(7).email, User.find(8).email, User.find(9).email], ActionMailer::Base.deliveries[@email_count].to
    end
  # end
end