require 'test_helper'

class CuratorMailerTest < ActionMailer::TestCase

  test 'released_records_to' do

    email = CuratorMailer.notify_curators([users(:user2)], [records(:in_daac_review)])

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['test@element84.com'], email.to
    assert_equal 'New Metadata Curation Tool Records Are Available', email.subject
    assert_equal read_fixture('notify_curators_text_part').join, email.text_part.body.to_s
    assert_equal read_fixture('notify_curators_html_part').join, email.html_part.body.to_s

  end

end