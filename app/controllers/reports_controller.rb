class ReportsController < ApplicationController
  before_filter :authenticate_user!
  
  def home
    @collection_ingest_count = Collection.all.length
    @cmr_total_collection_count = Cmr.total_collection_count

    @metric_set = MetricSet.new(Record.all)

    @records = Record.where(recordable_type: "Collection")

    @record_sets = Collection.ordered_revisions.values
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

      @review_counts = metric_set.completed_review_counts(Review.all.where(review_state: 1))
      @total_completed = metric_set.total_completed

      @field_colors = metric_set.color_counts
      @total_checked = @field_colors[0] + @field_colors[1] + @field_colors[2] + @field_colors[3]

      @red_flags = metric_set.red_flags

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
    report_list = []
    records_list.each_slice(2) {|(concept_id, revision_id)|
                                  new_record = Collection.find_record(concept_id, revision_id) 
                                  if new_record
                                    report_list.push(new_record)
                                  end
                                 }

    metric_set = MetricSet.new(report_list)

    @review_counts = metric_set.completed_review_counts(Review.all.where(review_state: 1))
    @total_completed = metric_set.total_completed

    @field_colors = metric_set.color_counts
    @total_checked = @field_colors[0] + @field_colors[1] + @field_colors[2] + @field_colors[3]

    @red_flags = metric_set.red_flags

    @updated_count = metric_set.updated_count
    @updated_done_count = metric_set.updated_done_count

    @quality_done_records = metric_set.quality_done_records                             
  end

end