class RecordsController < ApplicationController
  include RecordHelper

  before_filter :authenticate_user!
  before_filter :ensure_curation
  before_filter :find_record, only: [:show, :complete, :update]

  def refresh
    # a list of records added in update in format of
    # [["concept_id1", "revision_id1"], ["concept_id2", "revision_id2"]]
    total_added_records, total_failed_records = Cmr.update_records(current_user)

    flash[:notice] = Cmr.format_added_records_list(total_added_records).html_safe
    if !total_failed_records.empty?
      flash[:alert] = Cmr.format_failed_records_list(total_failed_records).html_safe
    end
    redirect_to (request.referrer || home_path)
  end

  def show
    @record_sections = @record.sections
    @bubble_data = @record.bubble_map

    @reviews = (@record.reviews.select {|review| review.completed?}).sort_by(&:review_completion_date)

    @user_review = @record.review(current_user.id)
  end

  def complete

    success = completion_success

    if success
      flash[:notice] = "Record has been successfully updated."
      redirect_to collection_path(id:1, concept_id: @record.recordable.concept_id)
    else
      redirect_to record_path(@record)
    end
  end

  def update
    if @record.closed?
      if !params["redirect_index"].nil?
        redirect_to review_path(id: params["id"], section_index: params["redirect_index"])
        return
      else
        redirect_to record_path(id: params["id"], section_index: params["section_index"])
        return
      end
    end

    #update result will == true if any updates were made to record on save
    update_result = @record.update_from_review(current_user, params["section_index"], params["recommendation"], params["color_code"], params["opinion"], params["discussion"], params["feedback"], params["feedback_discussion"])

    if update_result == -1
      flash[:error] = "Values were not updated in the system.  Please resave changes."
    elsif update_result == true
      #creating a review is one is not yet recorded
      #.review will create a review if one not found.
      review = @record.review(current_user.id)
      review.save

      @record.start_arc_review! if @record.open?
    end

    if params["redirect_index"].nil?
      redirect_to record_path(id: params["id"], section_index: params["redirect_index"])
    else
      redirect_to review_path(id: params["id"], section_index: params["redirect_index"])
    end
  end

  private

  def find_record
    @record = Record.find_by(id: params[:id])
    redirect_to home_path unless @record
  end

  def completion_success
    if !can?(:review_state, @record.state.to_sym)
      flash[:alert] = "You do not have permission to perform this action"
      return false
    end

    begin
      if @record.in_arc_review?
        @record.complete_arc_review!
      elsif @record.ready_for_daac_review?
        @record.release_to_daac!

        RecordNotifier.notify_daac_curators([@record])
      else
        @record.close!
      end
    rescue => e
      error_messages = e.failures.uniq.map { |failure| Record::REVIEW_ERRORS[failure] }
      flash[:alert] = error_messages.join(" ")
      false
    end
  end
end
