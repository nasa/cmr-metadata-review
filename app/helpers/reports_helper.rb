module ReportsHelper

  #calculating the proportional font size for each number or errors,
  #given the high and low numbers of errors in the set
  def problem_font_size(error_list, item_errors)
    max_font = 48
    min_font = 12
    error_range = (error_list[0][1] - error_list[-1][1]).to_f
    font_range = (max_font - min_font).to_f
    if error_range == 0
      return min_font.to_s
    end 

    item_difference = item_errors - error_list[-1][1]

    return ((font_range/error_range) * item_difference + min_font).to_s     
  end

  def list_past_months
    @review_month_counts = []
    #this should be optimized to bucket all the reviews in one run through
    [10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0].each do |month_count|
      total_count = (Review.all.select { |review| 
                                            if review.review_completion_date
                                              (DateTime.now.month - review.review_completion_date.month) >= month_count
                                            else
                                              false 
                                            end
                                        }).count
      @review_month_counts.push(total_count)
    end
    @review_month_counts
  end

end