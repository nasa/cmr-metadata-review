module RecordHelper

  def empty_contents(value)
    new_value = nil

    if value.is_a?(String)
      new_value = ""
    elsif value.is_a?(Array)
      cleared_list = value.map{ |x| empty_contents(x) }
      cleared_list = cleared_list.select { |item| item != "" }
      cleared_list = "" if cleared_list.empty?
      new_value = cleared_list
    elsif value.is_a?(Hash)
      new_value = {}
      value.each do |key, sub_value|
        new_value[key] = empty_contents(sub_value)
      end
    end

    new_value
  end

  def script_test(value)
    if value.nil? || value == ""
      return false
    end

    !(value.start_with?("OK", "ok", "Ok"))
  end

  def completed_reviews(reviews)
    reviews.reduce(0) { |sum, review| sum + review.review_state.to_i }
  end

  def daac_reviewer_ok?(record)
    !record.in_daac_review? || can?(:review_state, Record::STATE_IN_DAAC_REVIEW)
  end

  def complete_button_text(record)
    if record.ready_for_daac_review?
      "RELEASE TO DAAC"
    elsif record.in_daac_review?
      "CMR UPDATED"
    else
      "MARK AS DONE"
    end
  end

  def disable_complete_button?(reviews, record)
    completed_reviews(reviews) <= 1 || record.closed? || !daac_reviewer_ok?(record)
  end
end
