module ReportsHelper

  def list_past_months(daac = nil)
    review_month_counts = []

    review_list = if daac
      records = Record.daac(daac)
      records.map(&:reviews).flatten
    else
      Review.all
    end

    #this should be optimized to bucket all the reviews in one run through
    10.downto(0).to_a.each do |month_count|
      total_count = (review_list.select { |review|
                                            if review.review_completion_date
                                              (DateTime.now.month - review.review_completion_date.month) >= month_count
                                            else
                                              false
                                            end
                                        }).count
      review_month_counts.push(total_count)
    end
    review_month_counts
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
end
