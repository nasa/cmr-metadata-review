class CollectionScript
  def self.run_script(collection_record)
    collection_data = JSON.parse(collection_record.rawJSON)
    comment_hash = collection_record.new_comment_JSON

    #operate over comment hash
    comment_hash["concept_id"] = "OK"

    return comment_hash.to_json

  end


end