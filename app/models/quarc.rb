class Quarc
  QUARC_API = "https://quarc.nasa-impact.net"
  include Singleton

  def version
    response = HTTParty.get(
      "https://quarc.nasa-impact.net/version"
    )
    response = JSON.parse(response.body)
    response["pyQuARC"]
  end

  def validate(format, metadata)
    Tempfile.create do |file|
      file << metadata
      file.flush
      response = HTTParty.post(
        "#{QUARC_API}/validate",
        body: {
          format: format,
          file: File.open(file.path)
        }
      )
      if (response.code != 200)
        raise Errors::PyQuARCError, "PyQuARC Error22222: (#{response.body} #{response.status})"
      end
      response = JSON.parse(response.body)
      process(response)
    end
  end

  def process(validation_results)
    validation_results = validation_results["details"]
    result = {}
    validation_results.each do |error|
      errors = error["errors"]
      errors.keys.each do |field_path|
        parse_checks(field_path, errors, result)
      end
    end
    return result
  end

  def remove_doctype(field_path)
    pos = field_path.index("/")
    path = field_path
    unless pos.nil?
      path = field_path[pos + 1..]
    end
    return path
  end

  # Given the specified path and the check being applied, include the check result of the value/message to the "result" dictionary.
  # If the check is valid (no errors), just include "OK; "
  #
  # e.g. check_data = { "valid": false, "value": [ 43 ],
  # "message": [ "Warning: The abstract provided may be inadequate based on length." ],
  # "remediation": "Provide a more comprehensive description, mimicking a journal abstract that is useful to the science
  # community but also approachable for a first time user of the data." }
  def assign_results(path, check, check_data, result)
    if check_data.has_key?("valid")
      valid = check_data["valid"]
      # if check is valid, use "OK"
      if valid
        result[path] += "OK; " if result[path] === ""
      else
        # prior check said this was OK, but this check says not.
        result[path] = "" if result[path] == "OK; "

        # Use the message if we have one.
        if check_data.has_key?("message")
          result[path] += "" "<b>Errors:</b><ul>"
          check_data["message"].each do |message|
            result[path] += "<li>" + message + "</li>"
          end
          result[path] += "</ul>"
        end
        if check_data["remediation"]
          result[path] += "<b>Remediation:</b><br>" + check_data["remediation"]
        else
          # Otherwise just mention the check failed.
          result[path] += check + " failed<br>"
        end
      end
    end
  end

  # This just cleans up the result path, it will remove a trailing ; and if the result path's value == "" then will remove it altogher from the
  # dictionary, hence all checks passed.
  # e.g., result[path] = "OK; " will return "OK"
  def trim_results_path(results, path)
    if results[path].end_with?("; ")
      count = results[path].length - 2
      results[path] = results[path][0..count]
    end
    if results[path] == ""
      results.delete(path)
    end
  end

  # Main logic that parses through the errors for the specified field path and assigns the results of the checks to the "result" dictionary.
  # The "result" dictionary is ["path":"result1;result2;"]
  # e.g. see arc_response.json (in this directory) for an example of what errors looks like.
  def parse_checks(field_path, errors, result)
    path = remove_doctype(field_path)
    result[path] = ""
    checks = errors[field_path].keys
    checks.each do |check|
      check_data = errors[field_path][check]
      assign_results(path, check, check_data, result)
    end
    trim_results_path(result, path)
  end
end


