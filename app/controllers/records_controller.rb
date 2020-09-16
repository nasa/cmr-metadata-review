class RecordsController < ApplicationController
  include RecordHelper
  include SiteHelper

  before_action :authenticate_user!
  before_action :ensure_curation
  before_action :admin_only, only: [:stop_updates, :allow_updates, :revert]
  before_action :find_record, only: [:show, :complete, :update, :stop_updates, :allow_updates, :revert, :copy_prior_recommendations]

  def find_records_json
    page_num_param = params['page_num']
    page_size_param = params['page_size']
    filter_param = params['filter']
    sort_order_param = params['sort_order']
    sort_column_param = params['sort_column']
    color_code_param = params['color_code']
    state_param = params['state']

    state = get_state(state_param)
    if state=='closed_finished'
      state_query = " and records.state in ('closed','finished')"
    else
      if state == 'curator_feedback'
        state_query = " and records.state != 'closed'"
      else
        state_query = " and records.state='#{state}'"
      end
    end

    page_num = get_page_num(page_num_param)
    page_size = get_page_size(page_size_param)
    limit = page_size
    offset = (page_num - 1)*page_size

    sort_order = get_sort_order(sort_order_param)
    sort_column = get_sort_column(sort_column_param)

    filter = get_filter(filter_param)

    color_code = get_color_code(color_code_param)

    record_data_join = " LEFT JOIN record_data ON record_data.record_id = records.id"
    if state == 'curator_feedback'
      record_data_join = record_data_join + " and record_data.feedback=true"
    end

    review_join = " LEFT JOIN reviews ON reviews.record_id = records.id"
    if state == 'curator_feedback'
      review_join = review_join + " and reviews.user_id='#{current_user.id}'"
    end

    query = " from records" + " INNER JOIN collections ON records.recordable_id=collections.id" + record_data_join + review_join +
        " WHERE records.recordable_type = 'Collection'" + state_query + get_daac_query

    if filter
      query = query + " and (collections.concept_id like '%#{filter}%' or collections.short_name like '%#{filter}%')"
    end

    if color_code
      query = query + " and record_data.color='#{color_code}'"
    end

    if sort_column && sort_order
      query = query + " order by #{sort_column} #{sort_order}"
    end

    count_query = "select" + " count(distinct records.id) as count" + query

    query = query + " limit #{limit} offset #{offset}"
    records_query = "select" + " distinct records.id, records.state, records.format, collections.concept_id, records.revision_id, collections.short_name" + query

    puts "*** Records query=" + query

    response_records = Record.find_by_sql(records_query)

    record_second_opinion_counts = RecordData.where(record: response_records, opinion: true).group(:record_id).count

    reponse_array = []
    response_records.each do |record|
      reponse_array.push({"id":record.id, "state":record.state, "concept_id": record[:concept_id],
                          "revision_id": record.revision_id, "short_name": record[:short_name],
                          "version": record.version_id, "no_completed_reviews": record.completed_reviews(record.reviews),
                          "no_second_reviews_requested": record_second_opinion_counts[record.id].to_i})
    end
    puts "*** Count query=" + count_query
    count_result = ActiveRecord::Base.connection.exec_query(count_query)
    result = {total_count: count_result.rows[0][0], page_num: page_num, page_size: page_size, records: reponse_array}
    render json: result
  end

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
      unless granule_record.nil?
        success, messages = can_associate_granule?(granule_record, @record.state)
        unless success
          flash[:alert] = messages.join('<br>').html_safe
          flash[:notice] = 'Failed to associate granule.'
          redirect_to collection_path(id: collection.id, record_id: @record.id)
          return
        end
        granule = Granule.find_by id: granule_record.recordable_id
        granule_concept_id = granule.concept_id
        granule_revision_id = granule_record.revision_id
        granule_record.update(state: @record.state)
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
    prior_record = @record.prior_revision_record
    @prior_record_revision_id = prior_record.nil? ? '' : prior_record.revision_id
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
    unless session[:unhide_record_ids].nil?
      @unhide_record_ids = {}
      @unhide_record_ids[session[:unhide_state]] = session[:unhide_record_ids]
      session[:unhide_record_ids] = nil
      session[:unhide_state] = nil
    end
    
    @records = @records.where(state: [Record::STATE_CLOSED, Record::STATE_FINISHED])
  end

  def revert
    success = false
    Record.transaction do
      begin
        success = @record.revert!
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

  def unhide
    puts "Unhiding records...#{params.keys}"
    record_ids = params["unhide_form_record_ids"].split(' ').map(&:to_i)

    @records = Record.where(id: record_ids)
    msg = 'Undeleted the following collections: '

    msgItems = []
    @records.each do |record|
      record.update(state: params[:unhide_state])
      msgItems << "#{record.concept_id}/#{record.revision_id}"
    end
    msgItems.sort!
    msgItems.each do |message|
      msg += message + ' '
    end
    flash[:notice] = msg
    redirect_back(fallback_location: home_path)
  end


  def hide
    Rails.logger.info("#{current_user.uid} - Deleted the following record ids: #{params[:record_id]}")

    @unhide_form_record_ids = {}
    session[:unhide_state] = params[:unhide_state]
    session[:unhide_record_ids] = params[:record_id]

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
    concept_id = params[:concept_id]
    rev_id = params[:revision_id]
    if @record.recordable_type == 'Collection'
      prior_record = Collection.find_record(concept_id, rev_id)
    else
      prior_record = Granule.find_record(concept_id, rev_id)
    end
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
      if record.has_associated_granule?
        granule_record = Record.find_by id: record.associated_granule_value
        success, messages = can_mark_associated_granule_complete?(granule_record, record.state)
        unless success
          flash[:alert] = messages.join('<br>').html_safe
          return false
        end
      end

      if record.in_arc_review?
        success = record.complete_arc_review!
      elsif record.ready_for_daac_review?
        success = release_record_for_daac_review(record)
      else # in daac review
        can?(:force_close, record) ? record.force_close! : record.close!
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
      if record.collection?
        success = release_collection_record_to_daacs(record)
      else
        Rails.logger.error("Error encountered releasing record, type not known, #{record.recordable_type}")
        success = false
      end
      # special case kind of exception: the database transaction will be rolled back, without passing on the exception.
      raise ActiveRecord::Rollback, 'Error releasing record!' unless success
    end
    success
  end

  def release_collection_record_to_daacs(collection_record)
    collection_record.release_to_daac!
  end

  private

  def get_page_num(page_num)
    if page_num && page_num.match(/[0-9]+/)
      page_num.to_i
    else
      1
    end
  end

  def get_page_size(page_size)
    if page_size && page_size.match(/[0-9]+/)
      page_size.to_i
    else
      25
    end
  end

  def get_state(state)
    %w[open in_arc_review in_daac_review ready_for_daac_review closed hidden finished closed_finished curator_feedback].include?(state) ? state : 'open'
  end

  def get_sort_order(sort_order)
    %w[asc desc].include?(sort_order) ? sort_order : nil
  end

  def get_sort_column(sort_column)
    %w[concept_id short_name].include?(sort_column) ? sort_column : nil
  end

  def get_color_code(color_code)
    %w[gray yellow green red blue].include?(color_code) ? color_code : nil
  end

  def get_filter(filter)
    if filter
      filter.match(/[_A-Za-z0-9-]+/) ? filter : nil
    end
  end

  def get_daac_query
    query = ""
    if current_user.daac_curator?
      query = " and records.daac=#{current_user.daac}"
    elsif filtered_by?(:daac, ANY_DAAC_KEYWORD)
      query = " and records.daac=#{params[:daac]}"
    elsif Rails.configuration.mdq_enabled_feature_toggle
      query = application_mode == :mdq_mode ? get_provider_query(ApplicationHelper::MDQ_PROVIDERS) : get_provider_query(ApplicationHelper::ARC_PROVIDERS)
    end
    return query
  end

  def get_provider_query(provider_list)
    result = " and records.daac in ("
    provider_list.each { |provider|
      result = result + "'#{provider}',"
    }
    result.chop!
    result = result + ")"
    return result
  end

end
