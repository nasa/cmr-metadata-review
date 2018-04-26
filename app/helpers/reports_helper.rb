module ReportsHelper

  def records_with_reviews_by_month
    begin_date = (Date.today - 10.months).beginning_of_month
    end_date   = Date.today.end_of_month

    # Finds the records with reviews completed that month
    records = Record.joins(:reviews).where("reviews.review_completion_date >= :begin_date AND reviews.review_completion_date <= :end_date",
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
    closed = Record.closed
    closed = closed.daac(params[:daac]) if params[:daac]

    closed.count
  end

  def finished_records_count
    finished = Record.finished
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

  def record_data_titles
    @record_data_titles ||= @record_datas.pluck(:column_name).uniq
  end

  def csv_titles
   @csv_titles ||= (
    ["DataSetId (ShortName) - umm-json link"] +
      record_data_titles +
      [
        '# Red fields (absolute errors):',
        '# Yellow fields (recommended fixes)',
        '# Blue fields (observations/ may or may not need to be fixed)',
        '# np fields (not in the metadata, and not marked by any color)',
        '# fields checked',
        '% red fields',
        '% yellow fields',
        '% blue fields'
      ]
    )
  end

  def record_datas_organized_by_title(record)
    {}.tap do |data_hash|
      record.record_datas.each do |record_data|
        data_hash[record_data.column_name] = record_data
      end
    end
  end

  def generate_csv_line(record)
    line      = ["#{record.long_name} (#{record.short_name}) - #{record.umm_json_link}"]
    data_hash = record_datas_organized_by_title(record)

    record_data_titles.each do |title|
      data_string = nil
      if record_data = data_hash[title]
        data_string = "Color: #{record_data.color}\n"
        data_string += "Script Comment: #{record_data.script_comment}\n" unless record_data.script_comment.blank?
        data_string += "Recommendation: #{record_data.recommendation}" unless record_data.recommendation.blank?
      end

      line << data_string
    end

    red_fields     = record.record_datas.where(color: "red").count
    yellow_fields  = record.record_datas.where(color: "yellow").count
    blue_fields    = record.record_datas.where(color: "blue").count
    np_fields      = record.record_datas.where(script_comment: "np").count
    total_fields   = record.record_datas.count
    percent_red    = (red_fields.to_f / total_fields.to_f) * 100
    percent_blue   = (blue_fields.to_f / total_fields.to_f) * 100
    percent_yellow = (yellow_fields.to_f / total_fields.to_f) * 100

    data = [red_fields, yellow_fields, blue_fields, np_fields, total_fields,
      percent_red, percent_yellow, percent_blue]

    line + data
  end

  def cmr_total_collection_count
    @cmr_total_collection_count ||= Cmr.total_collection_count(params[:daac])
  end
end
