module RecordHelper

  def is_number?(object)
    true if Float(object) rescue false
  end

  # checks if the granule can be associated
  # note if the checks fail, the caller should not associate the granule record to the collection.
  def can_associate_granule?(granule_record, collection_state)
    # it is ok to associate granule records without checks if in open or in_arc_review
    return [true, nil] if %w(open in_arc_review).include?(collection_state)

    success = true
    messages = []
    unless granule_record.color_coding_complete?
      messages << 'Not all columns in the associated granule have been flagged with a color!'
      success = false
    end
    unless granule_record.has_enough_reviews?
      messages << 'The associated granule needs two completed reviews.'
      success = false
    end
    if %w(in_daac_review).include?(collection_state) && !granule_record.no_second_opinions?
      messages << 'Some columns in the associated granule still need a second opinion review.  Please clear all second opinion flags'
      success = false
    end
    [success, messages]
  end

  # checks if the granule can be marked complete
  # note: marking a record complete checks to see if it can move to the next state.
  def can_mark_associated_granule_complete?(granule_record, collection_state)
    # it is ok to associate granule records without checks if in open or in_arc_review
    success = true
    messages = []
    unless granule_record.color_coding_complete?
      messages << 'Not all columns in the associated granule have been flagged with a color!'
      success = false
    end
    unless granule_record.has_enough_reviews?
      messages << 'The associated granule needs two completed reviews.'
      success = false
    end
    if %w(ready_for_daac_review in_daac_review).include?(collection_state) && !granule_record.no_second_opinions?
      messages << 'Some columns in the associated granule still need a second opinion review.  Please clear all second opinion flags'
      success = false
    end
    [success, messages]
  end

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

  def reviewer_ok?(record)
    can?(:review_state, record.state.to_sym)
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
    completed_reviews(reviews) <= 1 || record.closed? || !reviewer_ok?(record)
  end

  def script_class(field)
    field[:script] && current_user.arc? ? "script" : "no_script"
  end

  def script_text_class(field)
    field[:script] && current_user.arc? ? "script_text" : "no_script_text"
  end

  def record_in_progress?(record)
    [Record::STATE_OPEN.to_s,
     Record::STATE_IN_ARC_REVIEW.to_s,
     Record::STATE_READY_FOR_DAAC_REVIEW.to_s].include?(record.state)
  end

  def should_show_copy_recommendations_button?(record)
    can?(:copy_recommendations, record) && !record.prior_revision_record.nil? && record_in_progress?(record)
  end

  def copy_recommendations_active_class(record)
    record.copy_recommendations_note.nil? ? 'eui-btn--green' : 'eui-btn--disabled'
  end
end
