module ReviewsHelper

  def color_selected_list(color)
    select_list = ["","","","","", ""]
    case color
    when "green"
      select_list[1] = "selected"
    when "blue"
      select_list[2] = "selected"
    when "yellow"
      select_list[3] = "selected"
    when "red"
      select_list[4] = "selected"
    when "gray"
      select_list[5] = "selected"
    else
      select_list[0] = "selected"
    end
    select_list
  end

  #Platforms/Platform0/ShortName -> Platforms / Platform 0 / ShortName
  def split_on_capitals(title)
    #adds a space before the / and adds a space before digits
    out_title = title.gsub("/", " / ")
    out_title = space_digits(out_title)
    out_title
  end

  def space_digits(title)
    return title.gsub(/([0-9]+)/, " \\1")
  end

  def format_new_lines(string)
    unless string.nil?
      return (raw string.gsub("\n", "<br>"))
    end
  end 

  def replace_links(values_hash)
    if values_hash.nil?
      return {}
    end
    
    new_values_hash = {}
    values_hash.each do |key, value|
      values_hash[key] = value.gsub(URI.regexp(['http', 'https'])) { |url| "<a target=\"_blank\" href=\"#{url}\">#{url}</a>" }
    end
    values_hash
  end

end