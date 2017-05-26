class ReportsController < ApplicationController
  include ReportsHelper

  before_filter :authenticate_user!
  
  def home
    @report_title = "OVERALL VIEW"
    @show_charts = true
    @csv_path = reports_home_path

    @collection_ingest_count = Collection.all.length
    @cmr_total_collection_count = Cmr.total_collection_count

    @review_month_counts = list_past_months

    # negative numbers represent previous months
    # then Date::MONTHNAMES[1..12] converts them into strings
    # the % 12 then wraps negative numbers around to the end months of the year
    @display_months = [-11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1].map {|month| Date::MONTHNAMES[1..12][((Date.today.month + month) % 12)]}

    @metric_set = MetricSet.new(Record.all)

    @records = Record.where(recordable_type: "Collection")

    record_set = Collection.all_newest_revisions

    #when views are redone, instantiate these as instance vars, then use directly in the 
    #view to get some DRY going accross all these views.
    metric_set = MetricSet.new(record_set)
    original_metric_set = metric_set.original_metric_set

    @review_counts = metric_set.completed_review_counts(Review.all.where(review_state: 1))
    @total_completed = metric_set.total_completed

    #stat generation for original and current sets of records
    @original_field_colors = original_metric_set.color_counts
    @original_total_checked = @original_field_colors.values.sum

    @original_quality_done_records = original_metric_set.quality_done_records

    @field_colors = metric_set.color_counts
    @total_checked = @field_colors.values.sum

    #taking the top 10 elements with the most issues
    @failing_elements_five = original_metric_set.element_non_green_count.take(10)

    @updated_count = metric_set.updated_count
    @updated_done_count = metric_set.updated_done_count

    @quality_done_records = metric_set.quality_done_records

    respond_to do |format|
      format.html
      format.csv { send_data(render_to_string, filename: "cmr_dashboard_metrics.csv") }
    end
  end

  def provider
    @report_title = "BY DAAC VIEW"
    @csv_path = reports_provider_path

    @provider_select_list = provider_select_list
    @provider_select_list[0] = "Select DAAC"

    unless params["daac"].nil? || params["daac"] == "Select DAAC"
      @show_charts = true
      @daac = params["daac"]
      @cmr_total_collection_count = Cmr.total_collection_count(@daac)
      @collection_ingest_count = Collection.by_daac(@daac).count

      daac_records = (Collection.by_daac(@daac).map {|collection| collection.records.to_a}).flatten
      daac_reviews = (daac_records.map {|record| record.reviews.to_a}).flatten

      @review_month_counts = list_past_months

      # negative numbers represent previous months
      # then Date::MONTHNAMES[1..12] converts them into strings
      # the % 12 then wraps negative numbers around to the end months of the year
      @display_months = [-11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1].map {|month| Date::MONTHNAMES[1..12][((Date.today.month + month) % 12)]}

      @percent_ingested = (@collection_ingest_count.to_f * 100 / @cmr_total_collection_count).round(2)

      record_set = Collection.all_newest_revisions(params["daac"])

      metric_set = MetricSet.new(record_set)
      original_metric_set = metric_set.original_metric_set

      @review_counts = metric_set.completed_review_counts(Review.all.where(review_state: 1))
      @total_completed = metric_set.total_completed

      #stat generation for original and current sets of records
      @original_field_colors = original_metric_set.color_counts
      @original_total_checked = @original_field_colors.values.sum

      @original_quality_done_records = original_metric_set.quality_done_records

      @field_colors = metric_set.color_counts
      @total_checked = @field_colors.values.sum


      @failing_elements_five = original_metric_set.element_non_green_count.take(5)

      @updated_count = metric_set.updated_count
      @updated_done_count = metric_set.updated_done_count

      @quality_done_records = metric_set.quality_done_records
    end

    respond_to do |format|
      format.html { render :template => "reports/home" }
      format.csv { send_data(render_to_string, filename: "#{@daac}_metrics.csv") }
    end
  end

  def search
    @free_text = params["free_text"]
    @provider = params["provider"]
    @curr_page = params["curr_page"]
    @provider_select_list = provider_select_list
    begin
      @search_iterator, @collection_count = Cmr.contained_collection_search(params["free_text"], params["provider"], params["curr_page"])
    rescue Cmr::CmrError
      flash[:alert] = 'There was an error connecting to the CMR System, please try again'
      redirect_to reports_search_path
      return
    rescue Net::OpenTimeout
      flash[:alert] = 'There was an error connecting to the CMR System, please try again'
      redirect_to reports_search_path
      return
    rescue Net::ReadTimeout
      flash[:alert] = 'There was an error connecting to the CMR System, please try again'
      redirect_to reports_search_path
      return
    rescue
      flash[:alert] = 'There was an error searching the system'
      redirect_to reports_search_path
      return
    end
  end

  def selection
    @show_charts = true
    @report_title = "SELECTION VIEW"
    @csv_path = reports_selection_path

    records_list = params["records"].split(",")
    @report_list = []
    records_list.each_slice(2) {|(concept_id, revision_id)|
                                  new_record = Collection.find_record(concept_id, revision_id) 
                                  if new_record
                                    @report_list.push(new_record)
                                  end
                                 }

    metric_set = MetricSet.new(@report_list)
    original_metric_set = metric_set.original_metric_set

    @review_counts = metric_set.completed_review_counts(Review.all.where(review_state: 1))
    @total_completed = metric_set.total_completed

    #stat generation for original and current sets of records
    @original_field_colors = original_metric_set.color_counts
    @original_total_checked = @original_field_colors.values.sum

    @original_quality_done_records = original_metric_set.quality_done_records

    @field_colors = metric_set.color_counts
    @total_checked = @field_colors.values.sum


    @failing_elements_five = original_metric_set.element_non_green_count.take(5)

    @updated_count = metric_set.updated_count
    @updated_done_count = metric_set.updated_done_count

    @quality_done_records = metric_set.quality_done_records

    respond_to do |format|
      format.html { render :template => "reports/home" }
      format.csv { send_data(render_to_string, filename: "cmr_selection_metrics.csv") }
    end                          
  end

end