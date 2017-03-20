class Cmr
  include ApplicationHelper
  include CmrHelper

  TIMEOUT_MARGIN = 10

  class CmrError < StandardError

  end


  def self.cmr_request(url)
    HTTParty.get(url, timeout: TIMEOUT_MARGIN)
  end

  def self.update_collections(current_user)
    last_date = RecordsUpdateLock.get_last_update
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

    return total_added_records
  end

  def self.collections_updated_since(date_string, page_num = 1)
    raw_updated = Cmr.cmr_request("https://cmr.earthdata.nasa.gov/search/collections.xml?page_num=#{page_num.to_s}&page_size=2000&updated_since=#{date_string.to_s}T00:00:00.000Z").parsed_response
  end

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
        collection_object, new_collection_record, record_data, ingest_record = Collection.assemble_new_record(data["concept_id"], data["revision_id"], current_user)
        #second check to make sure we don't save duplicate revisions
        unless Collection.record_exists?(collection_object.concept_id, new_collection_record.revision_id) 
          ActiveRecord::Base.transaction do
            new_collection_record.save!
            record_data.save!
            ingest_record.save!
          end

          new_collection_record.evaluate_script
          added_records.push([data["concept_id"], data["revision_id"]]);
        end
      end
    end
    return added_records
  end

  #cmr api auto returns only the most recent revision of a collection
  # &all_revisions=true&pretty=true" params can be used to find specific revision
  #we should only need to ingest the most recent versions.
  def self.get_collection(concept_id)
    collection_xml = Cmr.cmr_request("https://cmr.earthdata.nasa.gov/search/collections.echo10?concept_id=#{concept_id}").parsed_response
    begin
      collection_results = Hash.from_xml(collection_xml)["results"]
    rescue
      #error raised when no results are found.  CMR returns an error hash instead of xml string
      raise CmrError
    end

    if collection_results["hits"].to_i == 0
      raise CmrError
    end

    results_hash = flatten_collection(collection_results["result"]["Collection"])
    nil_replaced_hash = Cmr.remove_nil_values(results_hash)
    required_fields_hash = Cmr.add_required_collection_fields(nil_replaced_hash)
    required_fields_hash
  end

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

  def self.add_required_collection_fields(collection_hash)
    required_fields = ["ShortName", 
                        "VersionId", 
                        "InsertTime", 
                        "LastUpdate", 
                        "LongName", 
                        "DatasetId", 
                        "Description", 
                        "Orderable", 
                        "Visible",
                        "ProcessingLevelId", 
                        "ArchiveCenter", 
                        "DataFormat", 
                        "Temporal/Range/DateTime/BeginningDateTime", 
                        "Contacts/Contact/Role",
                        "ScienceKeywords/ScienceKeyword/CategoryKeyword",
                        "ScienceKeywords/ScienceKeyword/TopicKeyword",
                        "ScienceKeywords/ScienceKeyword/TermKeyword", 
                        "Platforms/Platform/ShortName", 
                        "Platforms/Platform/Instruments/Instrument/ShortName",
                        "Campaigns/Campaign/ShortName", 
                        "OnlineAccessURLs/OnlineAccessURL/URL", 
                        "Spatial/HorizontalSpatialDomain/Geometry/CoordinateSystem",
                        "Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle/WestBoundingCoordinate",
                        "Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle/NorthBoundingCoordinate",
                        "Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle/EastBoundingCoordinate",
                        "Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle/SouthBoundingCoordinate",
                        "Spatial/GranuleSpatialRepresentation"]

    keys = collection_hash.keys
    required_fields.each do |field|
      unless Cmr.keyset_has_field?(keys, field)
        collection_hash[field] = ""
      end
    end

    collection_hash
  end

  def self.keyset_has_field?(keys, field)
    split_field = field.split("/")
    regex = split_field.reduce("") {|sum, split_name| sum + split_name + ".*"}
    return (keys.select {|key| key =~ /^#{regex}/}).any?
  end

  def self.collection_granule_count(collection_concept_id)
    granule_list = Cmr.granule_list_from_collection(collection_concept_id)
    return granule_list["hits"].to_i
  end

  def self.granule_list_from_collection(concept_id, page_num = 1)
    granule_xml = Cmr.cmr_request("https://cmr.earthdata.nasa.gov/search/granules.echo10?concept_id=#{concept_id}&page_size=10&page_num=#{page_num}").parsed_response
    begin
      Hash.from_xml(granule_xml)["results"]
    rescue
      raise CmrError
    end
  end

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

  def self.collection_search(free_text, provider = ANY_KEYWORD, curr_page = "1")
    page_size = 10
    search_iterator = []

    if free_text
      query_text = "https://cmr.earthdata.nasa.gov/search/collections.echo10?keyword=?*#{free_text}?*&page_size=#{page_size}&page_num=#{curr_page}"

      #cmr does not accept first character wildcards for some reason, so remove char and retry query
      query_text_first_char = "https://cmr.earthdata.nasa.gov/search/collections.echo10?keyword=#{free_text}?*&page_size=#{page_size}&page_num=#{curr_page}"
      unless provider == ANY_KEYWORD
        query_text = query_text + "&provider=#{provider}"
        query_text_first_char = query_text_first_char + "&provider=#{provider}"
      end

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


  def self.format_added_records_list(list)
    if list.empty?
      return "No New Records Were Found"
    end
    output_string = "The following records and revision id\'s have been added<br/>"
    list.each do |record_list|
      output_string += "#{record_list[0]} - #{record_list[1]}<br/>"
    end
    return output_string
  end

end