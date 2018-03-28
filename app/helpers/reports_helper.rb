module ReportsHelper

  def closed_records_by_month
    begin_date = (Date.today - 10.months).beginning_of_month
    end_date   = Date.today.end_of_month

    records = Record.where("closed_date >= :begin_date AND closed_date <= :end_date",
      begin_date: begin_date, end_date: end_date)

    count = records.group("to_char(closed_date, 'YYYY-MM')").count

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
    closed = Record.closed
    closed = closed.daac(params[:daac]) if params[:daac]

    closed.count
  end

  def finished_records_count
    # TODO Update this to use the given scope when the finished
    # work is merged in
    finished = Record.where(state: "finished")
    finished = finished.daac(params[:daac]) if params[:daac]

    finished.count
  end

  def collection_finished_count
    @collection_finished_count ||= if params[:daac]
      Collection.by_daac(params[:daac]).finished.count
    else
      Collection.finished.count
    end
  end

  def cmr_total_collection_count
    @cmr_total_collection_count ||= Cmr.total_collection_count(params[:daac])
  end
end
