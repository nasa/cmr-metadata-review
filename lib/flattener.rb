module Flattener
  def flatten(collection, result = {}, key = '', suffix = '')
    collection.each do |k, value|
      refined_key = k.gsub(/\ /, '')
      if value.is_a?(Hash)
        flatten(value, result, key + "#{refined_key}/", suffix)
      elsif value.is_a?(Array)
        result.merge!(handle_multiple("#{key}#{refined_key}", value))
      else
        result["#{key}#{refined_key} #{suffix}"] = value
      end
    end
    result
  end

  def handle_multiple(key, elements)
    result = {}
    elements.each.with_index(1) do |element, index|
      if element.is_a?(Hash) || element.is_a?(Array)
        result.merge!(flatten(element, {}, key, "(#{index})"))
      else
        result["#{key} (#{index})"] = element
      end
    end
    result
  end
end