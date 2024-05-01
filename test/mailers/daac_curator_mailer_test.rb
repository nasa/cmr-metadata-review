require 'test_helper'
require "#{Rails.root}/lib/rake_helpers/daac_curator_mailer_helper"

class DaacCuratorMailerTest < ActionMailer::TestCase

  # context 'released_records_digest_notification email appearance' do
  test 'correctly populates the fields of an email' do
      email = DaacCuratorMailer.released_records_digest_notification([User.find(7), User.find(8)], [Record.find(22), Record.find(25)], 'OB_DAAC')

      assert_emails 1 do
        email.deliver_now
      end

      assert_equal ['fake_daac_curator1@fake.com', 'fake_daac_curator2@fake.com'], email.to
      assert_equal ['no-reply@earthdata.nasa.gov'], email.from
      assert_equal 'Summary of Reports Available to OB_DAAC', email.subject
      assert_equal read_fixture('released_records_digest_notification_text_part').join, email.text_part.body.to_s
      assert_equal read_fixture('released_records_digest_notification_html_part').join, email.html_part.body.to_s
    end
  # end
  
  # context 'finding all the users and records to send digest e-mails' do

  # end
end