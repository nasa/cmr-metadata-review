class ReportsController < ApplicationController
  include ReportsHelper

  before_filter :authenticate_user!

  def home
    @metric_data         = MetricData.new(Collection.all)
    @granule_metric_data = MetricData.new(Granule.all)

    respond_to do |format|
      format.html
      format.csv { send_data(render_to_string, filename: "cmr_dashboard_metrics.csv") }
    end
  end

  def provider
    if params[:daac] && params[:daac] != "Select DAAC"
      @metric_data         = MetricData.new(Collection.by_daac(params[:daac]))
      @granule_metric_data = MetricData.new(Granule.by_daac(params[:daac]))
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
    concept_ids = params[:records].split(",")

    @collections = Collection.where(concept_id: concept_ids)
    @granules    = @collections.map(&:granules).flatten

    @metric_data         = MetricData.new(@collections)
    @granule_metric_data = MetricData.new(@granules)

    respond_to do |format|
      format.html
      format.csv { send_data(render_to_string, filename: "cmr_selection_metrics.csv") }
    end
  end

  def single
    @record = Record.find(Array(params[:record_id]).first)
    @metric_set = MetricSet.new([@record])
    @field_colors = @metric_set.color_counts

    respond_to do |format|
      format.html
      format.csv { send_data(render_to_string, filename: "dashboard_#{record.concept_id}_#{record.revision_id}.csv") }
    end
  end
end
