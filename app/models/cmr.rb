class Cmr
  include ApplicationHelper
  include CmrHelper

  # Constant used to determine the timeout limit in seconds when connecting to CMR
  TIMEOUT_MARGIN = 10
  REQUIRED_COLLECTION_FIELDS = ["ShortName", 
                                "VersionId", 
                                "LastUpdate", 
                                "LongName", 
                                "DataSetId", 
                                "Description", 
                                "ProcessingLevelId", 
                                  [
                                    "ArchiveCenter",
                                    "ProcessingCenter"
                                    ],
                                "CollectionState", 
                                "DataFormat", 
                                  [
                                    "Temporal/SingleDateTime", 
                                    "Temporal/RangeDateTime/BeginningDateTime",
                                    "Temporal/PeriodicDateTime/Name"
                                    ],
                                "Contacts/Contact/Role",
                                "ScienceKeywords/ScienceKeyword/CategoryKeyword",
                                "ScienceKeywords/ScienceKeyword/TopicKeyword",
                                "ScienceKeywords/ScienceKeyword/TermKeyword", 
                                "Platforms/Platform/ShortName", 
                                "Platforms/Platform/Instruments/Instrument/ShortName",
                                "Campaigns/Campaign/ShortName", 
                                "OnlineAccessURLs/OnlineAccessURL/URL", 
                                "Spatial/HorizontalSpatialDomain/Geometry/CoordinateSystem",
                                [
                                  [
                                    "Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle/WestBoundingCoordinate",
                                    "Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle/NorthBoundingCoordinate",
                                    "Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle/EastBoundingCoordinate",
                                    "Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle/SouthBoundingCoordinate"
                                  ],
                                  [
                                    "Spatial/HorizontalSpatialDomain/Geometry/Point/PointLongitude",
                                    "Spatial/HorizontalSpatialDomain/Geometry/Point/PointLatitude"
                                  ],
                                  [
                                    "Spatial/HorizontalSpatialDomain/Geometry/Line/Point/PointLongitude",
                                    "Spatial/HorizontalSpatialDomain/Geometry/Line/Point/PointLatitude"
                                  ],
                                  [
                                    "Spatial/HorizontalSpatialDomain/Geometry/GPolygon/Boundary/Point/PointLatitude",
                                    "Spatial/HorizontalSpatialDomain/Geometry/GPolygon/Boundary/Point/PointLongitude"
                                  ]
                                ],
                                "Spatial/GranuleSpatialRepresentation"]

    REQUIRED_DIF10_FIELDS =    [
                                  "Entry_ID/Short_Name",
                                  "Entry_ID/Version",
                                  "Entry_Title",
                                  "Science_Keywords/Category",
                                  "Science_Keywords/Topic",
                                  "Science_Keywords/Term",
                                  "Platform/Short_Name",
                                  "Platform/Instrument/Short_Name",
                                  [
                                    "Temporal_Coverage/Range_DateTime/Beginning_Date_Time",
                                    "Temporal_Coverage/Single_Date_Time",
                                    [
                                      "Temporal_Coverage/Periodic_DateTime/Name",
                                      "Temporal_Coverage/Periodic_DateTime/Start_Date",
                                      "Temporal_Coverage/Periodic_DateTime/End_Date",
                                      "Temporal_Coverage/Periodic_DateTime/Duration_Unit",
                                      "Temporal_Coverage/Periodic_DateTime/Duration_Value",
                                      "Temporal_Coverage/Periodic_DateTime/Period_Cycle_Duration_Unit",
                                      "Temporal_Coverage/Periodic_DateTime/Period_Cycle_Duration_Value"
                                    ],
                                    [
                                      "Temporal_Coverage/Paleo_DateTime/Paleo_Start_Date",
                                      "Temporal_Coverage/Paleo_DateTime/Paleo_Stop_Date"
                                    ]
                                  ],
                                  "Data_Set_Progress",
                                  "Spatial_Coverage/Granule_Spatial_Representation",
                                  "Spatial_Coverage/Geometry/Coordinate_System", 
                                  [
                                    [
                                      "Spatial_Coverage/Geometry/Bounding_Rectangle/Southernmost_Latitude",
                                      "Spatial_Coverage/Geometry/Bounding_Rectangle/Northernmost_Latitude",
                                      "Spatial_Coverage/Geometry/Bounding_Rectangle/Westernmost_Longitude",
                                      "Spatial_Coverage/Geometry/Bounding_Rectangle/Easternmost_Longitude"
                                    ],
                                    [
                                      "Spatial_Coverage/Geometry/Point/Point_Longitude",
                                      "Spatial_Coverage/Geometry/Point/Point_Latitude"
                                    ],
                                    [
                                      "Spatial_Coverage/Geometry/Line/Point/Point_Longitude",
                                      "Spatial_Coverage/Geometry/Line/Point/Point_Latitude",
                                    ],
                                    [
                                      "Spatial_Coverage/Geometry/Polygon/Boundary/Point/Point_Longitude",
                                      "Spatial_Coverage/Geometry/Polygon/Boundary/Point/Point_Latitude"
                                    ]
                                  ],
                                  "Project/Short_Name",
                                  "Organization/Organization_Type",
                                  "Organization/Organization_Name/Short_Name",
                                  "Summary/Abstract",
                                  "Related_URL/URL_Content_Type/Type",
                                  "Related_URL/URL",
                                  "Product_Level_ID",
                                  "Metadata_Dates/Metadata_Creation",
                                  "Metadata_Dates/Metadata_Last_Revision",
                                  "Metadata_Dates/Data_Creation",
                                  "Metadata_Dates/Data_Last_Revision",
                                  "Dataset_Citation/Persistent_Identifier/Type",
                                  "Dataset_Citation/Persistent_Identifier/Identifier"
                                ]               


    REQUIRED_GRANULE_FIELDS =  ["GranuleUR",
                                "InsertTime",
                                "LastUpdate",
                                  [
                                    [
                                      "Collection/ShortName",
                                      "Collection/VersionId"
                                    ],
                                    "Collection/DataSetId"
                                  ],
                                "DataGranule/ProductionDateTime",
                                "OnlineAccessURLs/OnlineAccessURL/URL"] 



  # A custom error raised when items can not be found in the CMR.
  class CmrError < StandardError

  end

  # ====Params   
  # string url
  # ====Returns
  # HTTParty response object
  # ==== Method
  # Sends a request to the CMR system and returns the result
  # throws timeout error after time determined by TIMEOUT_MARGIN

  def self.cmr_request(url)
    HTTParty.get(url, timeout: TIMEOUT_MARGIN)
  end

  # ====Params   
  # User object
  # ====Returns
  # Array of Records
  # ==== Method
  # Takes the date of last update from the RecordsUpdateLock model
  # Queries the CMR for all records that have been updated since the "last update" minus one day.
  # checks the updated records list for records which have the same concept_id as as record in our system
  # Queries CMR again to download and ingest all updated records with matching concept_id
  # returns all of the updated records which match a concept_id

  def self.update_collections(current_user)
    update_lock = RecordsUpdateLock.find_by id: 1
    if update_lock.nil?
      #subtracting a year so that any older records picked up from an artificially setup starting set of records
      update_lock = RecordsUpdateLock.new(id: 1, last_update: (DateTime.now - 365.days))
    end
    
    last_date = update_lock.get_last_update
    #getting date into format
    #taking last update and going back a day to give cmr time to update
    search_date = (last_date - 1.days).to_s.slice(/[0-9]+-[0-9]+-[0-9]+/)
    page_num = 1
    result_count = 0
    total_results = Float::INFINITY
    #will return this list of added records for logging/presentation
    total_added_records = []

    #only 2000 results returned at a time, so have to loop through requests
    while result_count < total_results
      raw_results = Cmr.collections_updated_since(search_date, page_num)
      total_results = raw_results["results"]["hits"].to_i
      added_records = Cmr.process_updated_collections(raw_results, current_user)
      total_added_records = total_added_records.concat(added_records)

      result_count = result_count + 2000
      page_num = page_num + 1
    end

    update_lock.last_update = DateTime.now
    update_lock.save!

    return total_added_records
  end

  # ====Params   
  # string of date(no time), Integer 
  # ====Returns
  # Hash of CMR response
  # ==== Method
  # Queries cmr for collections updated since provided data, returns parsed response

  def self.collections_updated_since(date_string, page_num = 1)
    raw_updated = Cmr.cmr_request("https://cmr.earthdata.nasa.gov/search/collections.xml?page_num=#{page_num.to_s}&page_size=2000&updated_since=#{date_string.to_s}T00:00:00.000Z").parsed_response
  end


  # ====Params   
  # hash of CMR response, User object
  # ====Returns
  # Array of records
  # ==== Method
  # Filters provided CMR response to only the records that match concept_id's already in system
  # Ingests and saves all new records
  # Returns Array of the added record objects. 

  def self.process_updated_collections(raw_results, current_user)
    #mapping to hashes of concept_id/revision_id
    updated_collection_data = raw_results["results"]["references"]["reference"].map {|entry| {"concept_id" => entry["id"], "revision_id" => entry["revision_id"]} }
    #doing this eager loading to stop system from making each include? a seperate db call.
    all_collections = Collection.all.map{|collection| collection.concept_id }
    #reducing to only the ones in system
    contained_collections = updated_collection_data.select {|data| all_collections.include? data["concept_id"] }
    #will return this list of added records for logging/presentation
    added_records = []

    #importing the new ones if any
    contained_collections.each do |data|
      unless Collection.record_exists?(data["concept_id"], data["revision_id"]) 
        collection_object, new_collection_record, record_data_list, ingest_record = Collection.assemble_new_record(data["concept_id"], data["revision_id"], current_user)
        #second check to make sure we don't save duplicate revisions
        unless Collection.record_exists?(collection_object.concept_id, new_collection_record.revision_id) 
          ActiveRecord::Base.transaction do
            new_collection_record.save!
            record_data_list.each do |record_data|
              record_data.save!
            end
            ingest_record.save!
          end

          new_collection_record.evaluate_script
          added_records.push([data["concept_id"], data["revision_id"]]);
        end
      end
    end
    return added_records
  end

  # ====Params   
  # string concept_id, string data_type
  # ====Returns
  # Hash of the data contained in a CMR collection object
  # ==== Method
  # Retrieves the most recent revision of a collection from the CMR
  # then processes and returns the data   
  # Automatically returns only the most recent revision of a collection       
  # can add "&all_revisions=true&pretty=true" params to find specific revision      

  def self.get_collection(concept_id, data_format = "echo10")
    if data_format == "echo10"
      required_fields = REQUIRED_COLLECTION_FIELDS
    elsif data_format == "dif10"
      required_fields = REQUIRED_DIF10_FIELDS 
    else
      required_fields = []
    end
          
    raw_collection = Cmr.get_raw_collection(concept_id, data_format)

    results_hash = flatten_collection(raw_collection)
    nil_replaced_hash = Cmr.remove_nil_values(results_hash)
    required_fields_hash = Cmr.add_required_collection_fields(nil_replaced_hash, required_fields)
    required_fields_hash
  end

  # ====Params   
  # string 
  # ====Returns
  # string
  # ==== Method
  # Queries the CMR for a record's original format
  # This tells the user what format a record was uploaded to CMR in.
  # Uses the cmr internal atom format as this provides a standardized structure to get the "originalFormat" attribute from

  def self.get_raw_collection_format(concept_id)
    url = Cmr.api_url("collections", "atom", {"concept_id" => concept_id})
    collection_xml = Cmr.cmr_request(url).parsed_response
    collection_results = Hash.from_xml(collection_xml)["feed"]
    raw_format = collection_results["entry"]["originalFormat"].downcase
    if raw_format.include? "dif10"
      return "dif10"
    elsif raw_format.include? "echo10"
      return "echo10"
    else
      return raw_format
    end
  end

  # ====Params   
  # string, string
  # ====Returns
  # Hash
  # ==== Method
  # Queries the CMR for a metadata record
  # returns the response hash without processing
  # need the raw return format to run automated scripts against

  def self.get_raw_collection(concept_id, type = "echo10")
    url = Cmr.api_url("collections", type, {"concept_id" => concept_id})

    collection_xml = Cmr.cmr_request(url).parsed_response
    begin
      collection_results = Hash.from_xml(collection_xml)["results"]
    rescue
      #error raised when no results are found.  CMR returns an error hash instead of xml string
      raise CmrError
    end

    if collection_results["hits"].to_i == 0
      raise CmrError
    end

    if type == "echo10"
      collection_results["result"]["Collection"]
    elsif type == "dif10"
      collection_results["result"]["DIF"]
    end
  end

  # ====Params   
  # string, string
  # ====Returns
  # Hash
  # ==== Method
  # Queries the CMR for a metadata record
  # returns the response hash without processing
  # need the raw return format to run automated scripts against


  def self.get_raw_granule(concept_id)
    url = Cmr.api_url("granules", "echo10", {"concept_id" => concept_id})
    granule_xml = Cmr.cmr_request(url).parsed_response
    begin
      granule_results = Hash.from_xml(granule_xml)["results"]
    rescue
      raise CmrError
    end

    if granule_results["hits"].to_i == 0
      raise CmrError
    end

    granule_results["result"]["Granule"]
  end


  # ====Params   
  # accepts hash or array elements containing collection data
  # ====Returns
  # parameter with any nil contents removed
  # ==== Method
  # Method recursively travels through elements contained in parameter removing 
  # any nil values.
  def self.remove_nil_values(collection_element)

    if collection_element.is_a?(Hash)
      #removing nil values from hash
      collection_element.delete_if {|key,value| value.nil? }
      #recurring through remaining values
      collection_element.each do |key, value|
          collection_element[key] = Cmr.remove_nil_values(value)
      end
    elsif collection_element.is_a?(Array)
      #removing nils
      collection_element = collection_element.select {|element| element }
      #removing sub nils
      collection_element = collection_element.map {|element| Cmr.remove_nil_values(element)}
    end
    collection_element
  end

  # ====Params   
  # Hash containing collection data
  # ====Returns
  # Hash
  # ==== Method
  # Iterates through parameter hash adding any UMM required fields    
  # List of required fields set in hardcoded list within method

  def self.add_required_collection_fields(collection_hash, required_fields = REQUIRED_COLLECTION_FIELDS)
    keys = collection_hash.keys
    required_fields.each do |field|
      unless Cmr.keyset_has_field?(keys, field)
        collection_hash = Cmr.keyset_add_field(collection_hash, field)
      end
    end

    collection_hash
  end


  # ====Params
  # Hash of metadata keys and values    
  # String Field Name or List of String Field Names
  # ====Returns
  # Hash of metadata keys and values
  # ==== Method
  # Adds the field name parameter of the first string of the list to the hash
  # if the first entry of the list is a sub list, then the entire sub list is added to the hash


  def self.keyset_add_field(collection_hash, field)
    if field.is_a?(String)
      collection_hash[field] = ""
      return collection_hash
    elsif field.is_a?(Array)
      if field[0].is_a?(String)
        collection_hash[field[0]] = ""
      elsif field[0].is_a?(Array)
        field[0].each do |sub_field|
          collection_hash[sub_field] = ""
        end
      end
      return collection_hash 
    end
  end


  # ====Params   
  # Array of keys,     
  # String Field Name or List of String Field Names
  # Optional Boolean
  # ====Returns
  # Boolean
  # ==== Method
  # Checks a set of keys and returns boolean of keyset containing the string param or any of the strings in a given list
  # must_contain_all added to recognize that subarrays of arrays in the required fields list represent sets of fields which must occur together


  def self.keyset_has_field?(keys, field, must_contain_all = false)
    if field.is_a?(String)
      split_field = field.split("/")
      regex = split_field.reduce("") {|sum, split_name| sum + split_name + ".*"}
      return (keys.select {|key| key =~ /^#{regex}/}).any?

    elsif field.is_a?(Array)
      contains_field = false
      field.each do |sub_field|
        if must_contain_all
          contains_field = Cmr.keyset_has_field?(keys, sub_field, true)
        else
          if Cmr.keyset_has_field?(keys, sub_field, true)
            contains_field = true
          end
        end
        
      end

      return contains_field
    end
  end


  # ====Params   
  # string concept_id
  # ====Returns
  # Integer
  # ==== Method
  # Contacts the CMR system and then extracts the # of granules tied to a collection

  def self.collection_granule_count(collection_concept_id)
    granule_list = Cmr.granule_list_from_collection(collection_concept_id)
    return granule_list["hits"].to_i
  end

  # ====Params   
  # string concept_id,     
  # integer page number
  # ====Returns
  # Array of granule data hashes
  # ==== Method
  # Contacts the CMR system and pulls granule data related to conecept_id param     
  # Uses param page number and gets set of 10 results starting from that page.

  def self.granule_list_from_collection(concept_id, page_num = 1)
    url = Cmr.api_url("granules", "echo10", {"concept_id" => concept_id, "page_size" => 10, "page_num" => page_num})
    granule_xml = Cmr.cmr_request(url).parsed_response
    begin
      Hash.from_xml(granule_xml)["results"]
    rescue
      raise CmrError
    end
  end

  # ====Params   
  # string concept_id,     
  # integer number of granules to download
  # ====Returns
  # Array of granule data hashmaps
  # ==== Method
  # Contacts the CMR system and pulls granule data related to conecept_id param     
  # Uses a random number generator to select random granules from the overall list related to a collection


  def self.random_granules_from_collection(collection_concept_id, granule_count = 1)
    granule_data_list = []

    unless granule_count == 0
      granule_results = Cmr.granule_list_from_collection(collection_concept_id)
      total_granules = granule_results["hits"].to_i
        
      #checking if we asked for more granules than exist  
      if total_granules < granule_count
        return -1
      end

      granule_data_list = []

      #getting a random list of granules addresses within available amount
      granules_picked = (0...total_granules).to_a.shuffle.take(granule_count)
      granules_picked.each do |granule_address|
        #have to add 1 because cmr pages are 1 indexed
        page_num = (granule_address / 10) + 1
        page_item = granule_address % 10

        #cmr does not return a list if only one result
        if total_granules > 1
          granule_data = Cmr.granule_list_from_collection(collection_concept_id, page_num)["result"][page_item]
        else
          granule_data = Cmr.granule_list_from_collection(collection_concept_id, page_num)["result"]
        end
        granule_data_list.push(granule_data)
      end
    end

    return granule_data_list
  end


  # ====Params   
  # string free text         
  # string DAAC provider name    
  # string page number of results to jump to    
  # ====Returns
  # Array of collection search results data     
  # Integer total collection results found
  # ==== Method
  # Contacts the CMR system and uses the free text search API     
  # parses the results and then returns a group of 10 to show in paginated results.  


  def self.collection_search(free_text, provider = ANY_KEYWORD, curr_page = "1", page_size = 10)
    search_iterator = []
    collection_count = 0

    if free_text
      base_options = {"page_size" => page_size, "page_num" => curr_page}
      #setting the provider params
      if provider == ANY_KEYWORD
        base_options["provider"] = PROVIDERS
      else
        base_options["provider"] = provider
      end

      #setting the two versions of free text search we want to run (with/without first char wildcard)
      options = base_options.clone
      options["keyword"] = "?*#{free_text}?*"
      options_first_char = base_options.clone
      options_first_char["keyword"] = "#{free_text}?*"

      query_text = Cmr.api_url("collections", "echo10", options)

      #cmr does not accept first character wildcards for some reason, so remove char and retry query
      query_text_first_char = Cmr.api_url("collections", "echo10", options_first_char)
      
      begin
        raw_xml = Cmr.cmr_request(query_text).parsed_response
        search_results = Hash.from_xml(raw_xml)["results"]

        #rerun query with first wildcard removed
        if search_results["hits"].to_i == 0
          raw_xml = Cmr.cmr_request(query_text_first_char).parsed_response
          search_results = Hash.from_xml(raw_xml)["results"]
        end
      rescue
        raise CmrError
      end


      collection_count = search_results["hits"].to_i

      if search_results["hits"].to_i > 1
        search_iterator = search_results["result"]
      elsif search_results["hits"].to_i == 1
        search_iterator = [search_results["result"]]
      else
        search_iterator = []
      end
    end

    return search_iterator, collection_count
  end


  #chose to search json as xml parsing is way too slow when searching whole cmr
  def self.json_collection_search(free_text, provider = ANY_KEYWORD, curr_page = "1", page_size = 10)
    search_iterator = []

    if free_text
      query_text = Cmr.api_url("collections", "json", {"keyword" => "?*#{free_text}?*", "page_size" => page_size, "page_num" => curr_page})

      #cmr does not accept first character wildcards for some reason, so remove char and retry query
      query_text_first_char = Cmr.api_url("collections", "json", {"keyword" => "#{free_text}?*", "page_size" => page_size, "page_num" => curr_page})
      unless provider == ANY_KEYWORD
        query_text = query_text + "&provider=#{provider}"
        query_text_first_char = query_text_first_char + "&provider=#{provider}"
      end

      begin
        raw_json = Cmr.cmr_request(query_text).parsed_response
        search_results = raw_json["feed"]["entry"]

        #rerun query with first wildcard removed
        if search_results.length == 0
          raw_json = Cmr.cmr_request(query_text_first_char).parsed_response
          search_results = raw_json["feed"]["entry"]
        end
      rescue
        raise CmrError
      end
    end

    return search_results, search_results.length
  end

  def self.contained_collection_search(free_text = "", provider = ANY_KEYWORD, curr_page = "1", page_size = 2000)
    if free_text.nil?
      return [], 0
    end

    if free_text == "" && provider == ANY_KEYWORD
      all_collections = Collection.all_newest_revisions
      return all_collections, all_collections.length
    end

    total_search_iterator = []
    collection_count = 2000
    #using this loop to fill an array with all cmr collections that match search
    #2000 is cmr page limit, so there has to be multiple calls if results count over 2000
    while collection_count == 2000
      search_iterator, collection_count = Cmr.json_collection_search(free_text, provider, curr_page, page_size)
      total_search_iterator += search_iterator
      curr_page = (curr_page.to_i + 1).to_s
    end

    #changing all results to just the concept_id
    total_search_iterator.map! {|entry| entry["id"] }
    #going through all newest revisions in system and selecting those that were returned in the CMR search results
    total_search_iterator = Collection.all_newest_revisions.select {|record| total_search_iterator.include? record.concept_id }

    return total_search_iterator, total_search_iterator.length
  end


  def self.format_added_records_list(list)
    if list.empty?
      return "No New Records Were Found"
    end
    output_string = "The following records and revision id\'s have been added<br/>"
    list.each do |record_list|
      output_string += "#{record_list[0]} - #{record_list[1]} "
    end
    return output_string
  end

  def self.required_collection_field?(field_string, required_fields = REQUIRED_COLLECTION_FIELDS)
    #removing the numbers added to fields during ingest to seperate platforms/instruments
    stripped_field = field_string.gsub(/[0-9]/,'')
    is_required_field = false
    required_fields.each do |required_field| 
      if required_field.is_a?(String)
        if required_field == stripped_field
          is_required_field = true
        end
      elsif required_field.is_a?(Array)
        if Cmr.required_collection_field?(field_string, required_field)
          is_required_field = true
        end
      end
    end

    is_required_field
  end


  def self.api_url(data_type = "collections", format_type = "echo10", options = {})
    result = "https://cmr.earthdata.nasa.gov/search/" + data_type + "." + format_type + "?"
    options.each do |key, value| 
      #using list with flatten so that a string and list will both work as values
      [value].flatten.each do |single_value|
        result += (key.to_s + "=" + single_value.to_s + "&")
      end
    end
    result.chomp("&")
  end


  # ====Params   
  # Optional Sting of DAAC short name
  # ====Returns
  # Integer, total collections in the CMR     
  # ==== Method
  # Contacts CMR and obtains the total number of collections in the system for the EOSDIS daacs.
  # If Daac short name provided, only returns the total collections of that Daac.

  def self.total_collection_count(daac = nil)
    if daac.nil?
      options = {"page_size" => 1}
      options["provider"] = PROVIDERS
      url = Cmr.api_url("collections", "echo10", options)
    else 
      url = Cmr.api_url("collections", "echo10", {"page_size" => 1, "provider" => daac })
    end

    total_results = Cmr.cmr_request(url)
    results_hash = Hash.from_xml(total_results)["results"]
    results_hash["hits"].to_i
  end

end