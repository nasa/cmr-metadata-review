require 'test_helper'
require "#{Rails.root}/lib/rake_helpers/daac_curator_mailer_helper"

class DaacCuratorMailerTest < ActionMailer::TestCase

  describe 'released_records_digest_notification email appearance' do
    it 'correctly populates the fields of an email' do
      email = DaacCuratorMailer.released_records_digest_notification([User.find(7), User.find(8)], [Record.find(22), Record.find(25)], 'OB_DAAC')

      assert_emails 1 do
        email.deliver_now
      end

      assert_equal ['fake_daac_curator1@fake.com', 'fake_daac_curator2@fake.com'], email.to
      assert_equal ['no-reply@earthdata.nasa.gov'], email.from
      assert_equal 'Summary of Reports Available to OB_DAAC', email.subject
      assert_equal get_fixtures('daac_curator_mailer/released_records_digest_notification_text_part'), email.text_part.body.to_s
      assert_equal get_fixtures('daac_curator_mailer/released_records_digest_notification_html_part'), email.html_part.body.to_s
    end
  end
  
  describe 'finding all the users and records to send digest e-mails' do
    describe 'when two different daacs need e-mails' do
      before do
        @user1 = User.find(8)
        @user1.daac = 'NSIDC'
        @user1.save
        @email_count = ActionMailer::Base.deliveries.count
      end

      after do
        @user1.daac = 'OB_DAAC'
        @user1.save
      end

      it 'sends two e-mails when two DAACs have records in review' do
        # This time is a second Monday, so it should trigger weekly/daily emails
        DaacCuratorMailerOrchestration.released_records_digest_conductor(now: Time.new(2020, 2, 10))

        assert_equal @email_count + 2, ActionMailer::Base.deliveries.count
        # The e-mails are not consistently sent in the same order
        # Either, the first e-mail should match user 7 and the second match 8 or
        # the first should match 8 and the second 7
        assert (ActionMailer::Base.deliveries[@email_count].to == [User.find(7).email] && ActionMailer::Base.deliveries[@email_count + 1].to == [User.find(8).email]) ||
               (ActionMailer::Base.deliveries[@email_count].to == [User.find(8).email] && ActionMailer::Base.deliveries[@email_count + 1].to == [User.find(7).email])
      end
    end

    describe 'when users with different preferences are processed' do
      before do
        @email_count = ActionMailer::Base.deliveries.count
      end

      it 'sends one email to one recipient on a Tuesday' do
        DaacCuratorMailerOrchestration.released_records_digest_conductor(now: Time.new(2020, 2, 4))

        assert_equal @email_count + 1, ActionMailer::Base.deliveries.count
        assert_equal [User.find(7).email], ActionMailer::Base.deliveries[@email_count].to
      end

      it 'sends one email to four recipients on the first Monday' do
        DaacCuratorMailerOrchestration.released_records_digest_conductor(now: Time.new(2020, 2, 3))

        assert_equal @email_count + 1, ActionMailer::Base.deliveries.count
        assert_equal [User.find(7).email, User.find(8).email, User.find(9).email, User.find(10).email], ActionMailer::Base.deliveries[@email_count].to
      end

      it 'sends one email to two recipients on the second Monday' do
        DaacCuratorMailerOrchestration.released_records_digest_conductor(now: Time.new(2020, 2, 10))

        assert_equal @email_count + 1, ActionMailer::Base.deliveries.count
        assert_equal [User.find(7).email, User.find(8).email], ActionMailer::Base.deliveries[@email_count].to
      end

      it 'sends one email to three recipients on the third Monday' do
        DaacCuratorMailerOrchestration.released_records_digest_conductor(now: Time.new(2020, 2, 17))

        assert_equal @email_count + 1, ActionMailer::Base.deliveries.count
        assert_equal [User.find(7).email, User.find(8).email, User.find(9).email], ActionMailer::Base.deliveries[@email_count].to
      end
    end
  end
end