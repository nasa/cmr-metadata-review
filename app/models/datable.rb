# Module included with models that reference RecordData object
# Allows a standard set of commands to communicate with RecordData without having to use direct associations.
module Datable

  # ====Params   
  # ====Returns
  # Hash
  # ==== Method
  # Finds the RecordData object related to the parent class     
  # and extracts the data, returns a hash of the contained data      
  # Will initialize a new RecordData object if no existing objects found
  def values
    if self.record_data
      if self.record_data.rawJSON
        JSON.parse(self.record_data.rawJSON)
      end
    else
      new_raw_JSON = self.blank_JSON
      new_data = RecordData.new(datable: self, rawJSON: new_raw_JSON)
      new_data.save
      JSON.parse(new_raw_JSON)
    end
  end 

  # ====Params   
  # Hash
  # ====Returns
  # Void
  # ==== Method
  # Queries the DB and returns a record matching params    
  # if no record is found, returns nil.

  def update_values(new_value_hash)
    if self.record_data
      self.record_data.rawJSON = new_value_hash.to_json
      self.record_data.save
    else
      new_data = RecordData.new(datable: self, rawJSON: new_value_hash.to_json)
      new_data.save
    end
    nil
  end

  def update_partial_values(partial_hash)
    if partial_hash
      values = self.values
      partial_hash.each do |key, value|
        
          values[key] = value
      end
      self.update_values(values)
    end
  end

  def blank_JSON
    if self.is_a? Record 
      self.blank_comment_JSON
    else
      self.record.blank_comment_JSON
    end
  end

end