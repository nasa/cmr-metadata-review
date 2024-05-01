require 'test_helper'

class ReviewTest < ActiveSupport::TestCase

  # context "mark_complete" do
  test "correctly marks a review as complete" do
        record = Record.find_by id: 1

        first_review = record.add_review(1)
        first_review.mark_complete
        assert_equal(first_review.state_string, "Completed")
      end
  # end

  # context "formatted_date" do
  test "correctly formats the date before and after review completion" do
        record = Record.find_by id: 1
        first_review = record.add_review(1)
        assert_equal(first_review.state_string, "In Process")
        assert_equal((first_review.review_completion_date && (first_review.review_completion_date < DateTime.now) && (first_review.review_completion_date > (DateTime.now - 5000))), true)
        old_date = first_review.review_completion_date
        first_review.mark_complete
        assert_equal(first_review.state_string, "Completed")
        assert_equal((first_review.review_completion_date && (first_review.review_completion_date < DateTime.now) && (first_review.review_completion_date > (DateTime.now - 5000)) && first_review.review_completion_date > old_date), true)
        first_review.review_completion_date = "Tue, 28 Feb 2017 16:25:04 UTC +00:00"
        assert_equal(first_review.formatted_date, "02/28/2017 at 11:25AM")
      end
  # end

end
