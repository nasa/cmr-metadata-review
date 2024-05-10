class RecordsController < ApplicationController
  include RecordHelper
  include SiteHelper

  before_action :authenticate_user!
  before_action :ensure_curation
  before_action :admin_only, only: [:stop_updates, :allow_updates, :revert]
  before_action :find_record, only: [:show, :complete, :update, :stop_updates, :allow_updates, :revert, :copy_prior_recommendations]

  # http://localhost:3000/records/find_records_json?color_code=red
  def find_records_json
    page_num_param = params['page_num']
    page_size_param = params['page_size']
    filter_param = params['filter']
    sort_order_param = params['sort_order']
    sort_column_param = params['sort_column']
    color_code_param = params['color_code']
    color_code_filter_collection_param = params['color_code_filter_collection']
    color_code_filter_granule_param = params['color_code_filter_granule']
    state_param = params['state']
    daac_param = params['daac']
    campaign_param = params['campaign']

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
    color_code_filter_collection = get_bool(color_code_filter_collection_param, true)
    color_code_filter_granule = get_bool(color_code_filter_granule_param, false)

    record_data_join = " LEFT JOIN record_data ON record_data.record_id = records.id"

    review_join = " LEFT JOIN reviews ON reviews.record_id = records.id"

    ingest_join = " LEFT JOIN ingests ON ingests.record_id = records.id"

    recordable_type_filter = "records.recordable_type = 'Collection'"
    if (color_code)
      recordable_type_filter = "(records.recordable_type = 'Collection' or records.recordable_type = 'Granule')"
    end
    query = " from records" + " INNER JOIN collections ON records.recordable_id=collections.id" +
        record_data_join + review_join + ingest_join +
        " WHERE #{recordable_type_filter} " + state_query + get_daac_query(daac_param) + campaign_query(campaign_param) + curator_feedback_query

    if filter
      query = query + " and (lower(collections.concept_id) like lower('%#{filter}%') or lower(collections.short_name) like lower('%#{filter}%'))"
    end

    records_query = "select" + " distinct records.id, records.state, records.format, collections.concept_id," +
      " records.revision_id, collections.short_name, ingests.date_ingested" + query

    if (color_code)
      response_record_ids = ActiveRecord::Base.connection.exec_query(records_query).rows.map {|r|r[0]}
      response_record_ids = filter_by_color_code(response_record_ids, color_code, color_code_filter_collection, color_code_filter_granule)
      if response_record_ids.count == 0
        result = {total_count: 0, page_num: page_num, page_size: page_size, records: []}
        render json: result
        return
      end
      query = " from records INNER JOIN collections ON records.recordable_id=collections.id" +
        record_data_join + review_join + ingest_join +
        " WHERE #{recordable_type_filter}" + " and records.id in (#{response_record_ids.join(",")})"
    end

    count_query = "select" + " count(distinct records.id) as count" + query

    if sort_column && sort_order
      query = query + " order by #{sort_column} #{sort_order}"
    else
      query = query + " order by ingests.date_ingested DESC"
    end

    query = query + " limit #{limit} offset #{offset}"

    records_query = "select" + " distinct records.id, records.state, records.format, records.recordable_type, collections.concept_id," +
        " records.revision_id, collections.short_name, ingests.date_ingested" + query

    # puts "*** Records query=" + records_query
    response_records = Record.find_by_sql(records_query)

    record_second_opinion_counts = RecordData.where(record: response_records, opinion: true).group(:record_id).count

    response_array = []
    response_records.each do |record|
      record_format = (record[:format] == 'umm_json') ? 'umm-c' : record[:format]
    
      response_array.push({"id":record.id, "state":record.state, "concept_id": record[:concept_id],
      "date_ingested": record[:date_ingested], format: record_format,
      "revision_id": record.revision_id, "short_name": record[:short_name],
      "version": record.version_id, "no_completed_reviews": record.completed_reviews(record.reviews),
      "no_second_reviews_requested": record_second_opinion_counts[record.id].to_i})
    end

    count_result = ActiveRecord::Base.connection.exec_query(count_query)
    result = {total_count: count_result.rows[0][0], page_num: page_num, page_size: page_size, records: response_array}
    render json: result
  end

  def filter_by_color_code(response_record_ids, color_code, color_code_filter_collection, color_code_filter_granule)
    if color_code
      collection_response_record_ids = []
      granule_response_record_ids = []

      # retrieve all collection records with 'color_code'

      color_query = "record_data.color = '#{color_code}'"
      if color_code == 'any'
        color_query = "(record_data.color = 'red' or record_data.color = 'yellow' or record_data.color = 'blue')"
      end

      if color_code_filter_collection
        if response_record_ids.empty?
          collection_response_record_ids = ActiveRecord::Base.connection.exec_query("select distinct records.id, records.format  from records, record_data where records.id = record_data.record_id and #{color_query} and (records.state != 'closed' and records.state != 'finished') and records.recordable_type = 'Collection'").rows.map {|array|array[0]}
        else
          collection_response_record_ids = ActiveRecord::Base.connection.exec_query("select distinct records.id, records.format  from records, record_data where records.id = record_data.record_id and #{color_query} and (records.state != 'closed' and records.state != 'finished') and records.recordable_type = 'Collection' and records.id in (#{response_record_ids.join(",")})").rows.map {|array|array[0]}
        end
      end
      # retrieve all collection records where it has granules with 'color_code'

      granule_response_record_ids = Set.new
      if color_code_filter_granule
        granule_record_ids = ActiveRecord::Base.connection.exec_query("select distinct records.id, records.format from records, record_data where records.id = record_data.record_id and #{color_query} and (records.state != 'closed' and records.state != 'finished') and records.recordable_type = 'Granule'").rows.map {|array|array[0]}
        granule_record_ids.each do |granule_record_id|
          granule = (Record.find_by id: granule_record_id).recordable
          collection = Collection.find_by id: granule.collection_id
          records = collection.records
          records.each do |record|
            granule_response_record_ids << record.id
          end
        end
      end
      # only include records that are in either collection_records OR granule_records
      response_record_ids = response_record_ids.intersection(collection_response_record_ids.union(granule_response_record_ids.to_a))
    end
    response_record_ids
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

  def destroy
    @record = Record.find(params[:id])
    @record.destroy
    redirect_to root_path, notice: "Collection was successfully deleted."
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
    last_record_worked_on = nil
    @records.each do |r|
      last_record_worked_on = r.concept_id
      success = completion_success(r)
      break unless success
    end

    if success
      flash[:notice] = "Records were successfully updated"
    else
      flash[:notice] = "Error closing record #{last_record_worked_on}"
    end

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
    %w[concept_id short_name date_ingested format].include?(sort_column) ? sort_column : nil
  end

  def get_color_code(color_code)
    %w[gray yellow green red blue any].include?(color_code) || color_code=='' ? color_code : nil
  end

  def get_bool(value, default)
    value ? value == 'true' : default
  end

  def get_filter(filter)
    if filter
      filter.match(/[_A-Za-z0-9-]+/) ? filter : nil
    end
  end

  def campaign_query(campaign)
    if campaign && campaign != ANY_CAMPAIGN_KEYWORD
      " and '#{campaign}' = ANY (campaign)"
    else
      ""
    end
  end

  def curator_feedback_query
    if params[:state] == 'curator_feedback'
      if current_user.daac_curator?
        query = " and record_data.feedback=true and reviews.user_id = '#{current_user.id}'"
      else
        query = " and record_data.feedback=true"
      end
    else
      query = " and records.id not in (select distinct record_data.record_id from record_data where record_data.feedback = true)"
    end
    query
  end


  def get_daac_query(daac)
    query = ""
    if current_user.daac_curator?
      query = " and records.daac='#{current_user.daac}'"
    elsif daac && daac != ANY_DAAC_KEYWORD
      query = " and records.daac='#{daac}'"
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
