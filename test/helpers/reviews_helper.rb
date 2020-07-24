module Helpers
  module ReviewsHelper
    def assign_review_comments(review_comment_value, report_comment_value)
      # Set the review comment
      within '.review_comments' do
        review_comment = find('#review_review_comment')
        review_comment.set(review_comment_value)
        report_comment = find('#review_report_comment')
        report_comment.set(report_comment_value)
      end

      # Click the button Review Complete
      assert_no_css '#review_complete_button[disabled]'
      find('#review_complete_button').click
      assert_css '#review_complete_button[disabled]'
    end

    def accept_confirm_dialog
      if page.driver.class == Capybara::Selenium::Driver
        page.driver.browser.switch_to.alert.accept
      elsif page.driver.class == Capybara::Webkit::Driver
        sleep 1 # prevent test from failing by waiting for popup
        page.driver.browser.accept_js_confirms
      else
        raise "Unsupported driver"
      end
    end
  end
end
