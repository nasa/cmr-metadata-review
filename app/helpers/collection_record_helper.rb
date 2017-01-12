module CollectionRecordHelper

  def empty_contents(value)
    new_value = nil

    if value.is_a?(String)
      new_value = ""
    elsif value.is_a?(Array)
      cleared_list = value.map{ |x| empty_contents(x) }
      cleared_list = cleared_list.select { |item| item != "" }
      cleared_list = "" if cleared_list.empty?
      new_value = cleared_list
    elsif value.is_a?(Hash)
      new_value = {}
      value.each do |key, sub_value|
        new_value[key] = empty_contents(sub_value)
      end
    end

    return new_value
  end

end
