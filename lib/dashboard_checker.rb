require 'json'
require 'httpparty'
require 'faraday'
class PyQuARC
    @QUARC_API = "https://quarc.nasa-impact.net/validate"

    def validate(format, metadata)
      payload = {
        data: { 'format': format },
        files: { 'file': metadata }
      }
      Faraday.post(
        @QUARC_API,
        payload.to_json,
        "Content-Type" => "application/json"
      )
    end

    def process(json)
        result = {}
        validation_results = JSON.parse(json)
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
        if (pos != -1)
            path = field_path[pos+1..]
        end
        return path
    end
    
    def assign_results(path, check, check_data, result)
        if check_data.has_key?("valid")
            valid = check_data["valid"]
            if valid
                result[path] += "OK; " if result[path] === ""
            else
                result[path] == "" if result[path] == "OK; "
                if check_data.has_key?("message")
                    result[path] += "" "<b>Errors:</b><ul>"
                    check_data["message"].each do |message|
                        result[path] += "<li>"+message+"</li>"
                    end
                    result[path] += "</ul>"
                end
                if check_data.has_key?("remediation")
                    result[path] += "<b>Remediation:</b><br>"+check_data["remediation"]
                else
                    result[path] += check+" failed<br>"
                end
            end
        end
    end
    
    def trim_results_path(results, path)
        if results[path].end_with?("; ")
            count = results[path].length-2
            results[path] = results[path][0..count]
        end
        if results[path] == ""
            results.delete(path)
        end
    end
    
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

metadata= File.read("file.xml")
result = PyQuARC.new().validate('echo-c', metadata)
puts("#{result}")
#ARGV
