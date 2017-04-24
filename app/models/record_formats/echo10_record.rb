#RecordFormats are modules to be included in record objects upon initialization
#
#Since individual record formats have different underlying structures of RecordData objects
#unique accessors are needed for each format to access commonly requested data.
module RecordFormats::Echo10Record
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



  #should return a list where each entry is a (title,[title_list])
  def sections
    section_list = []
    
    contacts = self.get_section("Contacts/Contact")
    platforms = self.get_section("Platforms/Platform")
    campaigns = self.get_section("Campaigns/Campaign")
    temporal = self.get_section("Temporal")
    scienceKeywords = self.get_section("ScienceKeywords/ScienceKeyword")
    spatial = self.get_section("Spatial")
    online = self.get_section("OnlineResources/OnlineResource")
    accessURLs = self.get_section("OnlineAccessURLs")
    csdt = self.get_section("CSDTDescriptions")
    additional = self.get_section("AdditionalAttributes/AdditionalAttribute")

    section_list = section_list + contacts + platforms + campaigns + spatial + temporal + scienceKeywords + online + accessURLs + csdt + additional
    #finding the entries not in other sections
    used_titles = (section_list.map {|section| section[1]}).flatten
    all_titles = self.record_datas.map { |data| data.column_name }

    others = [["Collection Info", all_titles.select {|title| !used_titles.include? title }]]

    section_list = others + section_list
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
end