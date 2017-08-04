class RecordsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_curation

  def refresh
    # a list of records added in update in format of
    # [["concept_id1", "revision_id1"], ["concept_id2", "revision_id2"]]
    total_added_records, total_failed_records = Cmr.update_collections(current_user)

    flash[:notice] = Cmr.format_added_records_list(total_added_records).html_safe
    if !total_failed_records.empty?
      flash[:alert] = Cmr.format_failed_records_list(total_failed_records).html_safe
    end
    redirect_to (request.referrer || home_path)
  end

  def show
    @record = Record.find_by id: params["id"]
    if @record.nil?
      redirect_to home_path
      return
    end
    
    @record_sections = @record.sections
    @bubble_data = @record.bubble_map

    @reviews = (@record.reviews.select {|review| review.completed?}).sort_by(&:review_completion_date)
    @user_review = @record.review(current_user.id)

    @completed_records = (@reviews.map {|item| item.review_state == 1 ? 1:0}).reduce(0) {|sum, item| sum + item }
    @marked_done = @record.closed

    if ENV['SIT_SKIP_DONE_CHECK'] == 'true'
      @color_coding_complete = true
      @has_enough_reviews = true
      @no_second_opinions = true
      @granule_completed = true
    else
      @color_coding_complete = @record.color_coding_complete?
      @has_enough_reviews = @record.has_enough_reviews?
      @no_second_opinions = @record.no_second_opinions?
      @granule_completed = @record.granule_completed?
    end
  end

  def complete
    record = Record.find_by id: params["id"]
    if record.nil?
      redirect_to home_path
      return
    end

    if !(ENV['SIT_SKIP_DONE_CHECK'] == 'true')
      #checking that all bubbles are filled in
      if !record.color_coding_complete? || !record.has_enough_reviews? || !record.no_second_opinions? || !record.granule_completed?
        redirect_to record_path(record)
        return
      end
    end

    record.close

    flash[:notice] = "Record has been successfully marked as done"
    redirect_to collection_path(id:1, concept_id: record.recordable.concept_id)
  end

  def update
    record = Record.find_by id: params[:id]
    if record.nil?
      redirect_to home_path
      return
    elsif record.closed?
      if !params["redirect_index"].nil?
        redirect_to review_path(id: params["id"], section_index: params["redirect_index"])
        return 
      else 
        redirect_to record_path(id: params["id"], section_index: params["section_index"])
        return 
      end
    end

    #update result will == true if any updates were made to record on save
    update_result = record.update_from_review(current_user, params["section_index"], params["recommendation"], params["color_code"], params["opinion"], params["discussion"])

    if update_result == -1
      flash[:error] = "Values were not updated in the system.  Please resave changes."
    elsif update_result == true
      #creating a review is one is not yet recorded
      #.review will create a review if one not found.
      review = record.review(current_user.id)
      review.save
    end

    if params["redirect_index"].nil?
      redirect_to record_path(id: params["id"], section_index: params["redirect_index"])
    else
      redirect_to review_path(id: params["id"], section_index: params["redirect_index"])
    end
  end

end