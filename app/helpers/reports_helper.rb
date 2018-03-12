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
    # negative numbers represent previous months
    # then Date::MONTHNAMES[1..12] converts them into strings
    # the % 12 then wraps negative numbers around to the end months of the year
    (-11).upto(-1).to_a.map {|month| Date::MONTHNAMES[1..12][((Date.today.month + month) % 12)]}
  end

  def record_data_colors(record, color)
    record.record_datas.where(color: color)
  end
end
