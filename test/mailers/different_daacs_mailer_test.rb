require 'test_helper'
require "#{Rails.root}/lib/rake_helpers/daac_curator_mailer_helper"

class DifferentDaacsMailerTest < ActionMailer::TestCase
  # context 'when two different daacs need e-mails' do
  setup do
      @user1 = User.find(8)
      @user1.daac = 'NSIDC'
      @user1.save
      @email_count = ActionMailer::Base.deliveries.count
    end

  teardown do
      @user1.daac = 'OB_DAAC'
      @user1.save
    end

  test 'sends two e-mails when two DAACs have records in review' do
      # This time is a second Monday, so it should trigger weekly/daily emails
      DaacCuratorMailerOrchestration.released_records_digest_conductor(now: Time.new(2020, 2, 10))

      assert_equal @email_count + 2, ActionMailer::Base.deliveries.count
      # The e-mails are not consistently sent in the same order
      # Either, the first e-mail should match user 7 and the second match 8 or
      # the first should match 8 and the second 7
      assert (ActionMailer::Base.deliveries[@email_count].to == [User.find(7).email] && ActionMailer::Base.deliveries[@email_count + 1].to == [User.find(8).email]) ||
               (ActionMailer::Base.deliveries[@email_count].to == [User.find(8).email] && ActionMailer::Base.deliveries[@email_count + 1].to == [User.find(7).email])
    end
  # end
end