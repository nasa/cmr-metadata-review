module ReviewsHelper
  def script_result_value(value)
    if value.blank?
      "N/A"
    else
      raw value
    end
  end

  def color_selected_list(color)
    select_list = ['','','','','', '']
    case color
    when 'green'
      select_list[1] = 'selected'
    when 'blue'
      select_list[2] = 'selected'
    when 'yellow'
      select_list[3] = 'selected'
    when 'red'
      select_list[4] = 'selected'
    when 'gray'
      select_list[5] = 'selected'
    else
      select_list[0] = 'selected'
    end
    select_list
  end

  #Platforms/Platform0/ShortName -> Platforms / Platform 0 / ShortName
  def split_on_capitals(title)
    #adds a space before the / and adds a space before digits
    out_title = title.gsub('/', ' / ')
    out_title = space_digits(out_title)
    out_title
  end

  def space_digits(title)
    return title.gsub(/([0-9]+)/, ' \\1')
  end

  def format_new_lines(string)
    return (raw string.gsub("\n", '<br>')) unless string.nil?
  end 

  def replace_links(values_hash)
    return {} if values_hash.nil?
    
    new_values_hash = {}
    values_hash.each do |key, value|
      values_hash[key] = value.gsub(URI.regexp(['http', 'https'])) { |url| "<a target=\"_blank\" href=\"#{url}\">#{url}</a>" }
    end
    values_hash
  end
  
  def feedback_cell_class(current_user, feedback_title)
    feedback_class =  'request_review_feedback'
    feedback_class += if current_user.daac_curator?
                        ' feedback_cell review-toggle'
                      else
                        ' feedback_cell review-toggle-disabled'
                      end
    feedback_class += ' review-toggle__cell' if feedback_title
    feedback_class
  end

  def getFormReviewId(review)
    return 'review' + review.id.to_s
  end

  def getFormReportId(review)
    return 'report' + review.id.to_s
  end

  def getFormDiscussionId(discussion)
    return discussion.id.to_s
  end
end