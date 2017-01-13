class GranuleScript
  def self.run_script(granule_record)
    collection_data = JSON.parse(granule_record.rawJSON)
    comment_hash = granule_record.new_comment_JSON

    #operate over comment hash
    comment_hash["concept_id"] = "OK"

    return comment_hash.to_json

  end


end