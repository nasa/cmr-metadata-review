class ReportsController < ApplicationController
  include ReportsHelper

  before_filter :authenticate_user!

  def home
    @report_title = "OVERALL VIEW"
    @show_charts = true
    @csv_path = reports_home_path
    @csv_params = ""
    @collection_ingest_count = Collection.count
    @cmr_total_collection_count = Cmr.total_collection_count

    @review_month_counts = list_past_months
    @display_months = get_month_list

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
    @report_title = "BY DAAC VIEW"
    @csv_path = reports_provider_path
    @csv_params = params["daac"].nil? ? "" : "?daac=#{params["daac"]}"

    @provider_select_list = provider_select_list
    @provider_select_list[0] = "Select DAAC"

    unless params["daac"].nil? || params["daac"] == "Select DAAC"
      @show_charts = true
      @daac = params["daac"]
      @cmr_total_collection_count = Cmr.total_collection_count(@daac)
      @collection_ingest_count = Collection.by_daac(@daac).count

      daac_records = (Collection.by_daac(@daac).map {|collection| collection.records.to_a}).flatten
      daac_reviews = (daac_records.map {|record| record.reviews.to_a}).flatten

      @review_month_counts = list_past_months(daac_reviews)
      @display_months = get_month_list

      record_set = Collection.all_newest_revisions(params["daac"])
      @metric_set = MetricSet.new(record_set)
      @original_metric_set = @metric_set.original_metric_set

      @granule_metric_set = MetricSet.new(Granule.all_newest_revisions(params["daac"]))
      @granule_original_metric_set = @granule_metric_set.original_metric_set
    end

    respond_to do |format|
      format.html { render :template => "reports/home" }
      format.csv { send_data(render_to_string, filename: "#{@daac}_metrics.csv") }
    end
  end

  def search
    @provider_select_list = provider_select_list
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
    @show_charts = true
    @report_title = "SELECTION VIEW"
    @csv_path = reports_selection_path
    @csv_params = "?records=#{params["records"].to_s}"

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
      format.html { render :template => "reports/home" }
      format.csv { send_data(render_to_string, filename: "cmr_selection_metrics.csv") }
    end
  end

  def single
    @csv_path = reports_single_path
    @csv_params = "?record_id=#{params[:record_id]}"

    @record = Record.find(params[:record_id])

    record_data = @record.record_datas
    @reds = record_data.select{|data| data.color == "red"}
    @yellows = record_data.select{|data| data.color == "yellow"}
    @blues = record_data.select{|data| data.color == "blue"}

    @metric_set = MetricSet.new([@record])

    @field_colors = @metric_set.color_counts
    @total_checked = @field_colors.values.sum

    respond_to do |format|
      format.html
      format.csv { send_data(render_to_string, filename: "dashboard_#{record.concept_id}_#{record.revision_id}.csv") }
    end
  end

  private

  def get_month_list
    # negative numbers represent previous months
    # then Date::MONTHNAMES[1..12] converts them into strings
    # the % 12 then wraps negative numbers around to the end months of the year
    (-11).upto(-1).to_a.map {|month| Date::MONTHNAMES[1..12][((Date.today.month + month) % 12)]}
  end

end
