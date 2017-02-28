require 'test_helper'

class ReviewTest < ActiveSupport::TestCase

  it "returns correct results from formatted accessors" do
    record = Record.find_by id: 1

    first_review = record.add_review(1)
    assert_equal(first_review.state_string, "In Process")
    assert_equal(first_review.formatted_date, "")

    first_review.mark_complete
    assert_equal(first_review.state_string, "Completed")

    assert_equal((first_review.review_completion_date && (first_review.review_completion_date < DateTime.now) && (first_review.review_completion_date > (DateTime.now - 5000))), true)
    first_review.review_completion_date = "Tue, 28 Feb 2017 16:25:04 UTC +00:00"
    assert_equal(first_review.formatted_date, "02/28/2017 at 11:25AM")
  end

end
