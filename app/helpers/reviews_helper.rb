module ReviewsHelper

  def color_selected_list(color)
    select_list = ["","","","",""]
    case color
    when "green"
      select_list[1] = "selected"
    when "blue"
      select_list[2] = "selected"
    when "yellow"
      select_list[3] = "selected"
    when "red"
      select_list[4] = "selected"
    else
      select_list[0] = "selected"
    end
    select_list
  end

  #formats the titles from ShortName -> SHORT NAME
  def split_on_capitals(title)
    cap_list = title.split /(?=[A-Z])/
    #strip removes trailing whitespace
    (cap_list.reduce("") {|final_string, word| final_string + word.upcase + " " }).strip
  end

end