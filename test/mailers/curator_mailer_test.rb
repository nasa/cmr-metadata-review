require 'test_helper'

class CuratorMailerTest < ActionMailer::TestCase

<<<<<<< HEAD
  test 'released_records' do

    email = CuratorMailer.released_records([users(:user2)], [records(:in_daac_review)])
=======
  test 'released_records_to' do

    email = CuratorMailer.notify_curators([users(:user2)], [records(:in_daac_review)])
>>>>>>> 1eb0701... [CMRARC-227]: Adds email notifications when records move to DAAC review.

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['test@element84.com'], email.to
<<<<<<< HEAD
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

=======
    assert_equal 'New Metadata Curation Tool Records Are Available', email.subject
    assert_equal read_fixture('notify_curators_text_part').join, email.text_part.body.to_s
    assert_equal read_fixture('notify_curators_html_part').join, email.html_part.body.to_s

  end

>>>>>>> 1eb0701... [CMRARC-227]: Adds email notifications when records move to DAAC review.
end