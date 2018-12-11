module LogHelper
  def self.json_log(type, message, detail_message)
    json = {}
    json['type'] = type if type;
    json['message'] = LogHelper::truncate_string(message, 200) if message;
    json['detail_message'] = LogHelper::truncate_string(detail_message, 200) if detail_message;
    message = json.to_json;
    if (type == :info)
      Rails.logger.info(message)
    else
      Rails.logger.error(message)
    end
  end

  def self.truncate_cmr_tokens(message)
    return message.gsub(/Token \[(.*)\]/) {LogHelper::truncate_string($1, 10)}

  end

  def self.truncate_string(string, max)
    string = truncate_cmr_tokens(string)
    string.length > max ? "#{string[0...max]}..." : string
  end
end
