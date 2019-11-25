class RecordsController < ApplicationController
  include RecordHelper

  before_action :authenticate_user!
  before_action :ensure_curation
  before_action :admin_only, only: [:stop_updates, :allow_updates, :revert]
  before_action :find_record, only: [:show, :complete, :update, :stop_updates, :allow_updates, :revert, :copy_prior_recommendations]
  before_action :filtered_records, only: :finished

  def refresh
    added_records, deleted_records, failed_records = Cmr.update_collections(current_user)
    flash[:notice] = Cmr.format_added_records_list(added_records).html_safe
    unless failed_records.empty?
      flash[:alert] = Cmr.format_failed_records_list(failed_records).html_safe
    end
    unless deleted_records.empty?
      flash[:alert] = Cmr.format_deleted_records_list(deleted_records).html_safe
    end
    redirect_to(request.referrer || home_path)
  end

  def associate_granule_to_collection
    @record = Record.find_by id: params[:id]
    collection = Collection.find_by id: @record.recordable_id
    associated_granule_value = params[:associated_granule_value]

    success = false
    if associated_granule_value == 'Undefined'
      flash[:notice] = "This revision #{@record.revision_id} associated granule will be marked as 'Undefined'"
      success = @record.update(associated_granule_value: nil)
    elsif associated_granule_value == 'No Granule Review'
      flash[:notice] = "This revision #{@record.revision_id} associated granule will be marked as 'No Granule Review'"
      success = @record.update(associated_granule_value: associated_granule_value)
    elsif associated_granule_value == 'Granule Review Deleted!'
      flash[:notice] = "This revision #{@record.revision_id} associated granule is marked as 'Granule Review Deleted!"
      success = @record.update(associated_granule_value: associated_granule_value)
    else
      granule_record = Record.find_by id: associated_granule_value
      if !granule_record.nil?
        granule = Granule.find_by id: granule_record.recordable_id
        granule_concept_id = granule.concept_id
        granule_revision_id = granule_record.revision_id
        success = @record.update(associated_granule_value: granule_record.id)
        flash[:notice] = "Granule #{granule_concept_id}/#{granule_revision_id} has been successfully associated to this collection revision #{@record.revision_id}. "
      end
    end
    unless success
      flash[:notice] = 'An error occurred associating granule to the collection'
      Rails.logger.info "An error occurred associated granule to the collection, value=#{associated_granule_value}"
    end
    redirect_to collection_path(id: collection.id, record_id: @record.id)
  end

  def show
    @record_sections = @record.sections
    @bubble_data = @record.bubble_map

    @reviews = (@record.reviews.select {|review| review.completed?}).sort_by(&:review_completion_date)

    @user_review = @record.review(current_user.id)
  end

  def complete
    if completion_success(@record)
      flash[:notice] = "Record has been successfully updated."
      redirect_to collection_path(id: 1, record_id: @record.id)
    else
      flash[:notice] = 'Record failed to update.'
      redirect_to record_path(@record)
    end
  end

  def update
    if @record.closed? || @record.finished?
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

  def finished
    @records = @records.where(state: [Record::STATE_CLOSED, Record::STATE_FINISHED])
  end

  def revert
    success = false
    Record.transaction do
      begin
        success = @record.revert!
        success = revert_granule(@record) if success
      rescue StandardError => e
        Rails.logger.error("Error encountered reverting #{@record.concept_id}, #{e.message}")
        success = false
      end
      # special case kind of exception: the database transaction will be rolled back, without passing on the exception.
      raise ActiveRecord::Rollback, ' rollback Error reverting!' unless success
    end
    flash[:notice] = if success
                     "The record #{@record.concept_id} was successfully updated."
                   else
                     "Sorry, encountered an error reverting #{@record.concept_id}"
                   end
    redirect_to home_path
  end

  def stop_updates
    @record.finish!
    @record.recordable.finish! if @record.collection?

    flash[:notice] = "Concept ID #{@record.concept_id} has been marked finished"
    redirect_to finished_records_path
  end

  def allow_updates
    @record.allow_updates!
    @record.recordable.allow_updates! if @record.collection?

    flash[:notice] = "Concept ID #{@record.concept_id} will now allow CMR updates"
    redirect_to finished_records_path
  end

  def hide
    @records = Record.where(id: params[:record_id])
    msg = 'Deleted the following collections: '

    msgItems = []
    @records.each do |record|
      record.hide!
      msgItems << "#{record.concept_id}/#{record.revision_id}"
    end
    msgItems.sort!
    msgItems.each do |message|
      msg += message + ' '
    end
    flash[:notice] = msg
    redirect_back(fallback_location: home_path)
  end

  def batch_complete
    @records = Record.find(Array(params[:record_id]))

    success = false
    @records.each do |r|
      success = completion_success(r)
      break unless success
    end

    flash[:notice] = "Records were successfully updated" if success

    redirect_to (request.referrer || home_path)
  end

  def copy_prior_recommendations
    prior_record = @record.prior_revision_record
    if prior_record.nil?
      flash[:notice] = 'No prior revision could be found!'
    else
      copied, not_copied = @record.copy_recommendations(prior_record)
      Rails.logger.info "Successfully copied #{copied}/#{copied + not_copied} recommendations."
      flash[:notice] = 'Successfully copied recommendations.'
    end
    redirect_back(fallback_location: home_path)
  end

  private

  def find_record
    @record = Record.find_by(id: params[:id]) || Record.find_by(id: Array(params[:record_id]).first)
    redirect_to home_path unless @record
  end

  def completion_success(record)
    unless can?(:review_state, record.state.to_sym)
      flash[:alert] = "You do not have permission to perform this action"
      return false
    end

    begin
      if record.in_arc_review?
        success = record.complete_arc_review!
      elsif record.ready_for_daac_review?
        success = release_record_for_daac_review(record)
      else # in daac review
        can?(:force_close, record) ? record.force_close! : record.close!
        RecordNotifier.notify_closed([record])
        success = true
      end
      success
    rescue StandardError => e
      if e.respond_to?(:failures)
        error_messages = e.failures.uniq.map { |failure| Record::REVIEW_ERRORS[failure] }
        flash[:alert] = error_messages.join(" ")
      else
        flash[:alert] = e.message
      end
      false
    end
  end

  def release_record_for_daac_review(record)
    success = false
    Record.transaction do
      case record.recordable_type
      when 'Granule'
        success = release_granule_record_to_daacs(record)
      when 'Collection'
        success = release_collection_record_to_daacs(record)
      else
        Rails.logger.error("Error encountered releasing record, type not known, #{record.recordable_type}")
        success = false
      end
      # special case kind of exception: the database transaction will be rolled back, without passing on the exception.
      raise ActiveRecord::Rollback, 'Error releasing record!' unless success
    end
    RecordNotifier.notify_released([record]) if success
    success
  end

  # Check if collection record has assoc granule, if so, revert it.
  def revert_granule(collection_record)
    if !collection_record.associated_granule_value.nil? && is_number?(collection_record.associated_granule_value)
      granule_record = Record.find_by id: collection_record.associated_granule_value
      granule_record.revert!
    else
      true # doesn't have a granule, so return success
    end
  end

  # User chose to release granule record, also release the associated collection record
  def release_granule_record_to_daacs(granule_record)
    collection_record = Record.find_by associated_granule_value: granule_record.id
    # release the assoc collection record
    if !collection_record.nil?
      collection_record.release_to_daac! ? granule_record.release_to_daac! : false
    else
      granule_record.release_to_daac!
    end
  end

  # User chose to release collection record, also release the associated granule record
  def release_collection_record_to_daacs(collection_record)
    if !collection_record.associated_granule_value.nil? && is_number?(collection_record.associated_granule_value)
      # release the assoc granule record
      granule_record = Record.find_by id: collection_record.associated_granule_value
      granule_record.state = 'ready_for_daac_review' # dashboard data maybe inconsistent, so force this record to be in this state.

      granule_record.release_to_daac! ? collection_record.release_to_daac! : false
    else
      collection_record.release_to_daac! # release the collection record
    end
  end

end
