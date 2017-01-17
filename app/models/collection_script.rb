class CollectionScript
  def self.run_script(collection_record)
    collection_data = JSON.parse(collection_record.rawJSON)
    comment_JSON = collection_record.new_comment_JSON
    comment_hash = JSON.parse(comment_JSON)

    byebug
    #operate over comment hash

    #escaping json for passing to python
    collection_json = collection_data["Collection"].to_json.gsub("\"", "\\\"")

    #running collection script in python
    script_results = `python lib/CollectionChecker.py "#{collection_json}"`

    #parsing the prints from the script into sections
    script_results = script_results.split("\n")

    #removing any of the script results that have no text, ie ", " or ",  "
    script_results[1] = script_results[1].split(",").select { |entry| (!(entry =~ /[a-zA-Z0-9]/).nil?) }

    #splitting the row headers into a list
    script_results[3] = (script_results[3].split(",").select { |entry| (!(entry =~ /[a-zA-Z0-9]/).nil?) }).map { |entry| entry.gsub(/\s+/, "") }

    #creating a hash with values { row_header => result_string }
    comment_hash = Hash[script_results[3].zip(script_results[1])]

    return comment_hash.to_json

  end


end