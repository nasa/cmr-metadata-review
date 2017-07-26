#RecordFormats are modules to be included in record objects upon initialization
#
#Since individual record formats have different underlying structures of RecordData objects
#unique accessors are needed for each format to access commonly requested data.
module RecordFormats::Echo10Record
  SECTION_TITLES = ["Contacts/Contact", "Platforms/Platform", "Campaigns/Campaign", "Temporal", "ScienceKeywords/ScienceKeyword", "Spatial", "OnlineResources/OnlineResource", "OnlineAccessURLs", "CSDTDescriptions", "AdditionalAttributes/AdditionalAttribute"]

  include Echo10ControlledElements

  def get_section_titles
    SECTION_TITLES
  end

  # ====Params   
  # None
  # ====Returns
  # String
  # ==== Method
  # Accesses the record's RecordData attribute and then returns the value of the "LongName" field
  def long_name 
    self.get_column("LongName")
  end 

  # ====Params   
  # None
  # ====Returns
  # String
  # ==== Method
  # Accesses the record's RecordData attribute and then returns the value of the "ShortName" field
  def short_name
    self.get_column("ShortName")
  end

  # ====Params   
  # None
  # ====Returns
  # String
  # ==== Method
  # Accesses the record's RecordData attribute and then returns the value of the "VersionId" field
  def version_id
    self.get_column("VersionId")
  end


  def create_script(raw_data = nil)
      if raw_data.nil?
        raw_data = get_raw_data
      end
      comment_hash = self.evaluate_script(raw_data)
      score = score_script_hash(comment_hash)
      add_script_comment(comment_hash)
  end

  # ====Params   
  # optional Hash
  # ====Returns
  # Hash
  # ==== Method
  # This method runs the automated script against a record and then saves the result in a new ScriptComment object      
  # The script is run through a shell command which accesses the python scripts in the /lib directory.       
  # Parameter is optional hash of raw metadata from cmr for one record, if not provided, the raw data is manually retreived
  # Returns a formatted hash with results from script as values for each record field as keys.

  def evaluate_script(raw_data = nil)
    if raw_data.nil?
      raw_data = get_raw_data
    end
    #escaping json for passing to python
    record_json = raw_data.to_json.gsub("\"", "\\\"")
    #running collection script in python
    #W option to silence warnings
    if self.is_collection?  
      script_results = `python -W ignore lib/CollectionChecker.py "#{record_json}"  `
    else
      script_results = `python -W ignore lib/GranuleChecker.py "#{record_json}"`
    end

    unless script_results.nil?
      comment_hash = JSON.parse(script_results)
      value_keys = self.record_datas.map { |data| data.column_name }
      comment_hash = Record.format_script_comments(comment_hash, value_keys)
      comment_hash
    else
      {}
    end
  end

  def controlled_notice_list(element_list)
    controlled_map = {}
    element_list.map do |element|
      if CONTROLLED_ELEMENT_MAP.key? element
        controlled_map[element] = CONTROLLED_ELEMENT_MAP[element]
      end
    end
    controlled_map
  end
end