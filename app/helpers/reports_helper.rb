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

end