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
end