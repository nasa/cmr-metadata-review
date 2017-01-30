module ReviewsHelper

  def color_selected_list(color)
    case color
    when "green"
      ["", "selected", "", ""]
    when "yellow"
      ["", "", "selected", ""]
    when "red"
      ["", "", "", "selected"]
    else
      ["selected", "", "", ""]
    end
  end

  #formats the titles from ShortName -> SHORT NAME
  def split_on_capitals(title)
    cap_list = title.split /(?=[A-Z])/
    #strip removes trailing whitespace
    (cap_list.reduce("") {|final_string, word| final_string + word.upcase + " " }).strip
  end

end