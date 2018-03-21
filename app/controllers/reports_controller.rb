class ReportsController < ApplicationController
  include ReportsHelper

  before_filter :authenticate_user!

  def home
    @collection_finished_count = Collection.finished.count
    @cmr_total_collection_count = Cmr.total_collection_count

    @metric_set = MetricSet.new(Collection.all_newest_revisions)
    @original_metric_set = @metric_set.original_metric_set

    @granule_metric_set = MetricSet.new(Granule.all_newest_revisions)
    @granule_original_metric_set = @granule_metric_set.original_metric_set

    respond_to do |format|
      format.html
      format.csv { send_data(render_to_string, filename: "cmr_dashboard_metrics.csv") }
    end
  end

  def provider
    unless params[:daac].nil? || params[:daac] == "Select DAAC"
      @show_charts = true
      @cmr_total_collection_count = Cmr.total_collection_count(params[:daac])
      @collection_finished_count = Collection.by_daac(params[:daac]).finished.count

      record_set = Collection.all_newest_revisions(params[:daac])
      @metric_set = MetricSet.new(record_set)
      @original_metric_set = @metric_set.original_metric_set

      @granule_metric_set = MetricSet.new(Granule.all_newest_revisions(params["daac"]))
      @granule_original_metric_set = @granule_metric_set.original_metric_set
    end

    respond_to do |format|
      format.html
      format.csv { send_data(render_to_string, filename: "#{params[:daac]}_metrics.csv") }
    end
  end

  def search
    begin
      @search_iterator, @collection_count = Cmr.contained_collection_search(params[:free_text], params[:provider], params[:curr_page])
    rescue Cmr::CmrError, Net::OpenTimeout, Net::ReadTimeout
      flash[:alert] = 'There was an error connecting to the CMR System, please try again'
      redirect_to reports_search_path
    rescue
      flash[:alert] = 'There was an error searching the system'
      redirect_to reports_search_path
    end
  end

  def selection
    records_list = params["records"].split(",")
    @report_list = []
    @granule_report_list = []

    records_list.each_slice(2) {|(concept_id, revision_id)|
                                  new_record = Collection.find_record(concept_id, revision_id)
                                  if new_record
                                    @report_list.push(new_record)
                                    new_granule_record = new_record.related_granule_record
                                    if new_granule_record
                                      @granule_report_list.push(new_granule_record)
                                    end
                                  end
                                 }

    @metric_set = MetricSet.new(@report_list)
    @original_metric_set = @metric_set.original_metric_set

    @granule_metric_set = MetricSet.new(@granule_report_list)
    @granule_original_metric_set = @granule_metric_set.original_metric_set

    respond_to do |format|
      format.html
      format.csv { send_data(render_to_string, filename: "cmr_selection_metrics.csv") }
    end
  end

  def single
    @record = Record.find(params[:record_id])
    @metric_set = MetricSet.new([@record])
    @field_colors = @metric_set.color_counts

    respond_to do |format|
      format.html
      format.csv { send_data(render_to_string, filename: "dashboard_#{record.concept_id}_#{record.revision_id}.csv") }
    end
  end
end
