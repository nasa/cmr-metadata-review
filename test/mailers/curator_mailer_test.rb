require 'test_helper'

class CuratorMailerTest < ActionMailer::TestCase

  test 'released_records' do

    email = CuratorMailer.released_records([users(:user2)], [records(:in_daac_review)])

    assert_emails 1 do
      email.deliver_now
    end

    # assert_equal ['test@element84.co'], email.to
    assert_equal 'Metadata Curation Tool Released Records', email.subject
    assert_equal read_fixture('released_records_text_part').join, email.text_part.body.to_s
    assert_equal read_fixture('released_records_html_part').join, email.html_part.body.to_s

  end

  test 'closed_records' do
    email = CuratorMailer.closed_records([users(:user2)], [records(:closed)])

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['test@element84.com'], email.to
    assert_equal 'Metadata Curation Tool Closed Records', email.subject
    assert_equal read_fixture('closed_records_text_part').join, email.text_part.body.to_s
    assert_equal read_fixture('closed_records_html_part').join, email.html_part.body.to_s
  end

end