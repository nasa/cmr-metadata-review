module ReportsHelper
  include ApplicationHelper

  def records_with_reviews_by_month
    begin_date = (Date.today - 10.months).beginning_of_month
    end_date   = Date.today.end_of_month


    # Finds the records with reviews completed that month #
    records = Record.all_records(application_mode).joins(:reviews).where("reviews.review_completion_date >= :begin_date AND reviews.review_completion_date <= :end_date",
      begin_date: begin_date, end_date: end_date)

    # Counts the unique records that have a review in the month
    count = records.group("to_char(reviews.review_completion_date, 'YYYY-MM')").distinct.count

    10.downto(0).map do |month_mod|
      date = (Date.today - month_mod.months).strftime("%Y-%m")
      count[date].to_i
    end
  end

  def get_month_list
    (10).downto(0).map do |month_mod|
      date = Date.today - month_mod.months
      date.strftime("%b %y")
    end
  end

  def record_data_colors(record, color)
    record.record_datas.where(color: color)
  end

  def closed_records_count
    closed = Record.all_records(application_mode).closed
    closed = closed.daac(params[:daac]) if params[:daac]
    closed.count
  end

  def finished_records_count
    finished = Record.all_records(application_mode).finished
    finished = finished.daac(params[:daac]) if params[:daac]

    finished.count
  end

  def collection_finished_count
    @collection_finished_count ||= if params[:daac]
                                     Collection.by_daac(params[:daac]).finished.count
                                   else
                                     Collection.all_metadata(application_mode).finished.count
                                   end
  end

  def cmr_total_collection_count()
    @cmr_total_collection_count ||= Cmr.total_collection_count(params[:daac], provider_list)
  end

  def get_field_colors(record)
    MetricSet.new([record]).color_counts
  end
end
