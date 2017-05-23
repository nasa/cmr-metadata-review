class ReportsController < ApplicationController
  include ReportsHelper

  before_filter :authenticate_user!
  
  def home
    @collection_ingest_count = Collection.all.length
    @cmr_total_collection_count = Cmr.total_collection_count

    @review_day_counts = []
    #this should be optimized to bucket all the reviews in one run through
    [10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0].each do |month_count|
      total_count = (Review.all.select { |review| 
                                            if review.review_completion_date
                                              (DateTime.now.month - review.review_completion_date.month) >= month_count
                                            else
                                              false 
                                            end
                                        }).count
      @review_day_counts.push(total_count)
    end

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


    #test numbers for the graphs
    @review_day_counts = [2,10,20,30,50,75,82, 99, 110, 124, 143] 
    @original_field_colors = {"blue" => 7, "green" => 200, "yellow" => 12, "red" => 50}
    @field_colors = {"blue" => 7, "green" => 240, "yellow" => 12, "red" => 10}
    @collection_ingest_count = 245
    @failing_elements_five[0][1] = 72
    @failing_elements_five[1][1] = 50
    @failing_elements_five[2][1] = 45
    @failing_elements_five[3][1] = 12
    @failing_elements_five[4][1] = 10
    @collection_ingest_count = 2000

    respond_to do |format|
      format.html
      format.csv { send_data(render_to_string, filename: "cmr_dashboard_metrics.csv") }
    end
  end

  def provider
    @provider_select_list = provider_select_list
    @provider_select_list[0] = "Select DAAC"

    unless params["daac"].nil? || params["daac"] == "Select DAAC"
      @daac = params["daac"]
      @total_collection_count = Cmr.total_collection_count(@daac)
      @total_ingested = Collection.by_daac(@daac).count

      @percent_ingested = (@total_ingested.to_f * 100 / @total_collection_count).round(2)

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
      format.html
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
      format.html
      format.csv { send_data(render_to_string, filename: "cmr_selection_metrics.csv") }
    end                          
  end

end