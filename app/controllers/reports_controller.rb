class ReportsController < ApplicationController
  before_filter :authenticate_user!
  
  def home
    @collection_ingest_count = Collection.all.length
    @cmr_total_collection_count = Cmr.total_collection_count

    @review_day_counts = []
    [30,60,180].each do |day_count|
      total_count = (Review.all.select { |review| 
                                            if review.review_completion_date
                                              (DateTime.now - review.review_completion_date.to_datetime).to_i.days < day_count.days
                                            else
                                              false 
                                            end
                                        }).count
      @review_day_counts.push(total_count)
    end

    @metric_set = MetricSet.new(Record.all)

    @records = Record.where(recordable_type: "Collection")

    record_set = Collection.all_newest_revisions

    metric_set = MetricSet.new(record_set)
    original_metric_set = metric_set.original_metric_set

    @review_counts = metric_set.completed_review_counts(Review.all.where(review_state: 1))
    @total_completed = metric_set.total_completed

    #stat generation for original and current sets of records
    @original_field_colors = original_metric_set.color_counts
    @original_total_checked = @original_field_colors.values.sum
    @original_flag_counts = original_metric_set.flag_counts
    @original_quality_done_records = original_metric_set.quality_done_records

    @field_colors = metric_set.color_counts
    @total_checked = @field_colors.values.sum
    @flag_counts = metric_set.flag_counts

    @failing_elements_five = original_metric_set.element_non_green_count.take(5)

    @updated_count = metric_set.updated_count
    @updated_done_count = metric_set.updated_done_count

    @quality_done_records = metric_set.quality_done_records
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
      @original_flag_counts = original_metric_set.flag_counts
      @original_quality_done_records = original_metric_set.quality_done_records

      @field_colors = metric_set.color_counts
      @total_checked = @field_colors.values.sum
      @flag_counts = metric_set.flag_counts

      @failing_elements_five = original_metric_set.element_non_green_count.take(5)

      @updated_count = metric_set.updated_count
      @updated_done_count = metric_set.updated_done_count

      @quality_done_records = metric_set.quality_done_records
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
      redirect_to home_path
      return
    rescue Net::OpenTimeout
      flash[:alert] = 'There was an error connecting to the CMR System, please try again'
      redirect_to home_path
      return
    rescue Net::ReadTimeout
      flash[:alert] = 'There was an error connecting to the CMR System, please try again'
      redirect_to home_path
      return
    rescue
      flash[:alert] = 'There was an error searching the system'
      redirect_to home_path
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
    @original_flag_counts = original_metric_set.flag_counts
    @original_quality_done_records = original_metric_set.quality_done_records

    @field_colors = metric_set.color_counts
    @total_checked = @field_colors.values.sum
    @flag_counts = metric_set.flag_counts

    @failing_elements_five = original_metric_set.element_non_green_count.take(5)

    @updated_count = metric_set.updated_count
    @updated_done_count = metric_set.updated_done_count

    @quality_done_records = metric_set.quality_done_records                          
  end

end