class Cmr
  include ApplicationHelper
  include CmrHelper

  # Constant used to determine the timeout limit in seconds when connecting to CMR
  TIMEOUT_MARGIN = 10


  # A custom error raised when items can not be found in the CMR.
  class CmrError < StandardError
  end

  class UnsupportedFormatError < StandardError
  end

  # ====Params
  # string url
  # ====Returns
  # HTTParty response object
  # ==== Method
  # Sends a request to the CMR system and returns the result
  # throws timeout error after time determined by TIMEOUT_MARGIN

  def self.isTestUser(current_user)
    return true if current_user.nil? || current_user.access_token.blank? || current_user.access_token == 'accesstoken'
    false
  end

  def self.cmr_request(url)
    begin
      user = UserSingleton.instance
      current_user = user.current_user
      contents = if isTestUser(current_user)
                   HTTParty.get(url, timeout: TIMEOUT_MARGIN)
                 else
                   HTTParty.get(url, timeout: TIMEOUT_MARGIN, headers: {
                                  'Echo-Token' => user.echo_token
                                })
                 end
      truncated_contents = ApplicationHelper::truncate_string(contents, 200)
      Rails.logger.info("cmr_request - Calling external resource with #{url}, contents=#{truncated_contents}")
      return contents
    rescue Net::ReadTimeout
      Rails.logger.error("cmr_request - ReadTimeout calling #{url}")
      nil
    end
  end

  # ====Params
  # User object
  # ====Returns
  # [Array of Added Records, Array of Failed Records]
  # ==== Method
  # Gets a List of All Records in Open, In Arc Review, and Ready for DAAC Review
  # Determines what the latest revision id is for each record
  # Queries CMR to determine the latest revision id for the record
  # If Cmr revision id isn't the latest, we pull the latest and ingest it.

  def self.update_collections(current_user)
    if current_user.mdq_user?
      records = Record.all_records(:mdq_mode).where state: [Record::STATE_OPEN.to_s, Record::STATE_IN_ARC_REVIEW.to_s, Record::STATE_READY_FOR_DAAC_REVIEW.to_s], recordable_type: "Collection"
    else
      records = Record.all_records(:arc_mode).where state: [Record::STATE_OPEN.to_s, Record::STATE_IN_ARC_REVIEW.to_s, Record::STATE_READY_FOR_DAAC_REVIEW.to_s], recordable_type: "Collection"
    end

    added_records = []
    failed_records = []
    deleted_records = []
    processed = []

    # Returns a dictionary [ConceptId:LatestRevisionId] of every collection record in CMR.
    cmr_revision_map = self.get_cmr_revision_map

    records.each do |record|
      collection = record.recordable
      next if processed.include? collection.concept_id
      processed << collection.concept_id

      records = collection.records.where('state != ?', Record::STATE_HIDDEN.to_s).order('revision_id DESC')
      ids = records.map { |a| a.revision_id.to_i }
      ids.sort!
      latest_revision_id = ids.empty? ? -1 : ids.last
      cmr_revision_id = cmr_revision_map[record.concept_id].to_i

      if cmr_revision_id > latest_revision_id
        begin
          new_record = Collection.create_new_record(record.concept_id, cmr_revision_id, current_user, false)
          added_records << [record.concept_id, cmr_revision_id]
          Rails.logger.info "refresh-record NEW #{record.concept_id} #{record.revision_id} #{cmr_revision_id}"
        rescue Timeout::Error
          Rails.logger.error("refresh-record py-cmr timeout error #{record.concept_id} #{record.revision_id}")
          failed_records << [record.concept_id, cmr_revision_id]
        rescue StandardError => e
          Rails.logger.error("refresh-record error #{record.concept_id} #{record.revision_id} #{e.message}")
          failed_records << [record.concept_id, cmr_revision_id]
        end
      else
        Rails.logger.info "refresh-record EXISTS #{record.concept_id} #{record.revision_id} #{cmr_revision_id}"
        deleted_records << [record.concept_id, latest_revision_id]
      end
    end

    update_lock = RecordsUpdateLock.find_by id: 1
    if update_lock.nil?
      update_lock = RecordsUpdateLock.new
      update_lock.id = 1
    end
    update_lock.last_update = DateTime.now
    update_lock.save!
    [added_records, deleted_records, failed_records]
  end

  #
  # Queries CMR and returns a dictionary [ConceptId:LatestRevisionId] of every collection record in CMR.
  #
  def self.get_cmr_revision_map
    max_page_size = 2000
    page_no = 1
    no_pages = 1
    cmr_revision_map = {}

    user = UserSingleton.instance
    current_user = user.current_user

    conn = Faraday.new(:url => "#{Cmr.get_cmr_base_url}") do |faraday|
      faraday.headers['Echo-Token'] = user.echo_token unless isTestUser(current_user)
      faraday.response :logger
      faraday.adapter Faraday.default_adapter
    end

    while  page_no <= no_pages
      response = conn.get "/search/collections.umm-json?page_size=#{max_page_size}&page_num=#{page_no}&updated_since=#{URI.encode('1971-01-01T12:00:00-04:00')}"
      headers = response.headers
      if page_no == 1
        no_hits = headers['cmr-hits'].to_i
        no_pages = (no_hits / max_page_size) + 1
      end
      dict = JSON.parse(response.body)
      items = dict['items']
      items.each do |item|
        meta = item['meta']
        cmr_revision_map[meta['concept-id']] = meta['revision-id']
      end

      page_no += 1
    end

    cmr_revision_map

  end


  def self.current_revision_for(concept_id)
    base_url = Cmr.get_cmr_base_url
    url = "#{base_url}/search/collections.xml?concept_id[]=#{concept_id}"
    result =  Cmr.cmr_request(url).parsed_response

    revision = -1
    if result['results']['hits'].to_i > 0
      revision = result['results']['references']['reference']['revision_id'].to_i
    end

    revision
  end

  # ====Params
  # string of date(no time), Integer
  # ====Returns
  # Hash of CMR response
  # ==== Method
  # Queries cmr for collections updated since provided data, returns parsed response

  def self.collections_updated_since(date_string, page_num = 1)
    base_url = Cmr.get_cmr_base_url
    raw_updated = Cmr.cmr_request("#{base_url}/search/collections.xml?page_num=#{page_num.to_s}&page_size=2000&updated_since=#{date_string.to_s}T00:00:00.000Z").parsed_response
  end

  # ====Params
  # string concept_id, string data_type
  # ====Returns
  # Hash of the data contained in a CMR collection object
  # ==== Method
  # Retrieves the most recent revision of a collection from the CMR
  # then processes and returns the data
  # Automatically returns only the most recent revision of a collection
  # can add "&all_revisions=true" params to find specific revision
  def self.get_collection(concept_id, data_format = "echo10")
    raw_collection = get_raw_collection(concept_id, data_format)
    format_collection(raw_collection, data_format)
  end

  def self.convert_to_hash(data_format, collection_data)
    if data_format == "umm_json"
      JSON.parse(collection_data)
    else
      doc = Nokogiri.XML(collection_data)
      remove_empty_tags(doc)
      Hash.from_xml(doc.to_s)
    end
  end


  def self.remove_empty_tags(node)
    # post order traversal of DOM to remove leaf nodes that have no content
    # i.e., <Instruments/>
    node.children.each do |child|
      remove_empty_tags(child)
      # if is a leaf node and content is empty
      if child.count == 0 && child.content.gsub(/\s+/, '').empty?
        child.remove
      end
    end
  end

  def self.get_collection_by_url(url, data_format)
    collection_data = cmr_request(url).parsed_response

    if collection_data["errors"]
      error_message = data_format == "umm_json" ? collection_data["errors"] : collection_data["error"]
      raise CmrError, error_message
    end

    collection_data_hash = convert_to_hash(data_format, collection_data)

    raw_collection = if data_format == "echo10"
      collection_data_hash["Collection"]
    elsif data_format == "dif10"
      collection_data_hash["DIF"]
    elsif data_format == "umm_json"
      collection_data_hash
    end

    format_collection(raw_collection, data_format)
  end

  def self.format_collection(raw_collection, data_format = "echo10")
    desired_fields = if data_format == "echo10"
      RecordFormats::Echo10Fields::DESIRED_FIELDS
    elsif data_format == "dif10"
      RecordFormats::Dif10Fields::DESIRED_FIELDS
    elsif data_format == "umm_json"
      RecordFormats::UmmFields::DESIRED_FIELDS
    else
      []
    end

    results_hash   = flatten_collection(raw_collection)
    # Dif10 records come in with some uneeded header values
    results_hash = Cmr.remove_header_values(results_hash)
    add_required_fields(results_hash, desired_fields)
  end

  def self.get_granule(concept_id)
    granule_raw_data = Cmr.get_raw_granule(concept_id)
    format_granule_data(granule_raw_data)
  end

  def self.get_granule_with_collection_data(concept_id)
    granule_data            = get_raw_granule_results(concept_id)
    granule_data["Granule"] = format_granule_data(granule_data["Granule"])
    granule_data
  end

  def self.format_granule_data(granule_raw_data)
    results_hash = flatten_collection(granule_raw_data)
    add_required_fields(results_hash, RecordFormats::Echo10Fields::DESIRED_GRANULE_FIELDS)
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
    raw_format = collection_results["entry"]["originalFormat"].downcase if collection_results["entry"]

    raise CmrError.new("Native Format not found") unless raw_format

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
    url  = Cmr.api_url("collections", type, {"concept_id" => concept_id})
    data = Cmr.cmr_request(url).parsed_response

    begin
      collection_results = convert_to_hash(type, data)
      # dif10 and echo10 return results subelement but umm does not
      if type != 'umm_json'
        collection_results = collection_results['results']
      end
    rescue => e
      # Error raised when no results are found.  CMR returns an error hash instead of xml string
      raise CmrError, e.message
    end

    if collection_results["hits"].to_i == 0
      raise CmrError, "CMR returned 0 hits for #{concept_id}, type=echo10"
    end

    if type == "echo10"
      collection_results["result"]["Collection"]
    elsif type == "dif10"
      collection_results["result"]["DIF"]
    elsif type == "umm_json"
      collection_results["items"].first["umm"]
    end
  end

  def self.get_raw_collection_meta(concept_id)
    url  = Cmr.api_url('collections', 'umm_json', {'concept_id' => concept_id})
    data = Cmr.cmr_request(url).parsed_response
    collection_results = convert_to_hash('umm_json', data)
    collection_results['items'].first['meta']
  end


  # ====Params
  # string, string
  # ====Returns
  # Hash
  # ==== Method
  # Queries the CMR for a metadata record
  # returns the response hash without processing
  # need the raw return format to run automated scripts against
  # Only Echo10 records pull in granules pre business rules.
  # See Collection::INCLUDE_GRANULE_FORMATS

  def self.get_raw_granule(concept_id)
    granule_results = get_raw_granule_results(concept_id)
    granule_results["Granule"]
  end

  def self.get_raw_granule_results(concept_id)
    url = Cmr.api_url("granules", "echo10", {"concept_id" => concept_id})
    granule_xml = Cmr.cmr_request(url).parsed_response

    unless granule_xml['errors'].nil?
      raise CmrError.new, granule_xml['errors']['error']
    end

    begin
      granule_results = convert_to_hash("echo10", granule_xml)["results"]
    rescue => e
      raise CmrError, e.message
    end

    if granule_results["hits"].to_i == 0
      raise CmrError, "CMR returned 0 hits for #{concept_id}"
    end

    granule_results["result"]
  end

  # returns true if a granule with the specified concept id exists in cmr
  def self.raw_granule?(concept_id)
    url = Cmr.api_url('granules', 'echo10', 'concept_id': concept_id)
    response = Cmr.cmr_request(url)
    if response.code != 200
      Rails.logger.info "Error retrieving raw granule #{concept_id}, error=#{response.parsed_response}"
      return false
    end
    granule_hash = convert_to_hash('echo10', response.parsed_response)
    granule_results = granule_hash['results']
    granule_results['hits'].to_i.positive?
  end


  # ====Params
  # Hash containing collection data
  # ====Returns
  # Hash
  # ==== Method
  # Iterates through parameter hash adding any UMM required fields
  # List of required fields set in hardcoded list within method

  def self.add_required_fields(collection_hash, required_fields)
    required_fields.each do |field|
      collection_hash[field] = "" unless collection_hash[field]
    end

    collection_hash
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
    rescue => e
      raise CmrError, e.message
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
        return []
      end

      granule_data_list = []

      #getting a random list of granules addresses within available amount
      # CMR limits the page depth to 1,000,000, see ticket CMRARC-480
      total_granules = [1000000, total_granules].min
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


  def self.collection_search(free_text, provider, provider_list, curr_page="1", page_size=10)
    provider = ANY_DAAC_KEYWORD if provider.nil?

    search_iterator = []
    collection_count = 0

    if free_text
      free_text = free_text.strip
      base_options = {'page_size' => page_size, 'page_num' => curr_page}
      #setting the provider params
      if provider == ANY_DAAC_KEYWORD
        base_options['provider'] = provider_list + ['LARC_ASDC', 'LARC'] +
          ['NSIDCV0', 'NSIDC_ECS'] + ['GHRC', 'GHRC_CLOUD', 'LANCEAMSR2']
      else
        base_options['provider'] = provider
        base_options['provider'] = ['LARC_ASDC', 'LARC'] if provider == 'ASDC'
        base_options['provider'] = ['NSIDCV0', 'NSIDC_ECS'] if provider == 'NSIDC'
        base_options['provider'] = ['GHRC', 'GHRC_CLOUD', 'LANCEAMSR2'] if provider == 'GHRC'
      end

      #setting the two versions of free text search we want to run (with/without first char wildcard)
      options = base_options.clone
      options['keyword'] = "*#{free_text}*"
      options_first_char = base_options.clone
      options_first_char['keyword'] = "#{free_text}*"

      query_text = Cmr.api_url('collections', 'echo10', options)

      #cmr does not accept first character wildcards for some reason, so remove char and retry query
      query_text_first_char = Cmr.api_url('collections', 'echo10', options_first_char)

      begin
        raw_xml = Cmr.cmr_request(query_text).parsed_response
        search_results = Hash.from_xml(raw_xml)['results']

        #rerun query with first wildcard removed
        if search_results['hits'].to_i == 0
          raw_xml = Cmr.cmr_request(query_text_first_char).parsed_response
          search_results = Hash.from_xml(raw_xml)['results']
          if search_results['hits'].to_i > 0
            Rails.logger.info("cmr search for #{free_text} with wildcard on suffix ONLY worked.")
          end
        end
      rescue => e
        raise CmrError, e.message
      end


      collection_count = search_results['hits'].to_i

      if search_results['hits'].to_i > 1
        search_iterator = search_results['result']
      elsif search_results['hits'].to_i == 1
        search_iterator = [search_results['result']]
      else
        search_iterator = []
      end
    end

    return search_iterator, collection_count
  end


  #chose to search json as xml parsing is way too slow when searching whole cmr
  def self.json_collection_search(free_text, provider = ANY_DAAC_KEYWORD, curr_page = "1", page_size = 10)
    search_iterator = []

    if free_text
      query_text = Cmr.api_url("collections", "json", {"keyword" => "?*#{free_text}?*", "page_size" => page_size, "page_num" => curr_page})

      #cmr does not accept first character wildcards for some reason, so remove char and retry query
      query_text_first_char = Cmr.api_url("collections", "json", {"keyword" => "#{free_text}?*", "page_size" => page_size, "page_num" => curr_page})
      unless provider == ANY_DAAC_KEYWORD
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
      rescue => e
        raise CmrError, e.message
      end
    end

    return search_results, search_results.length
  end

  def self.contained_collection_search(free_text = "", provider = ANY_DAAC_KEYWORD, curr_page = "1", page_size = 2000, application_mode = :arc_mode)
    if free_text.nil?
      return [], 0
    end

    if free_text == "" && provider == ANY_DAAC_KEYWORD
      all_collections = Collection.all_newest_revisions(nil, application_mode)
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
    total_search_iterator = Collection.all_newest_revisions(nil, application_mode).select {|record| total_search_iterator.include? record.concept_id }

    return total_search_iterator, total_search_iterator.length
  end


  # Given the specified concept id, revision id, format fetch the concept from CMR and returns the concept as a hash.
  def self.get_concept(concept_id, revision_id = nil, format = nil)
    url = "#{Cmr.get_cmr_base_url}/search/concepts/#{concept_id}#{revision_id.nil? ? "" : "/#{revision_id}"}#{format.nil? ? "" : ".#{format}"}"
    convert_to_hash(format, Cmr.cmr_request(url).body)
  end

  def self.format_added_records_list(list)
    if list.empty?
      return "No New Records Were Found"
    end
    output_string = "The following records and revision id\'s have been added "
    list.each do |record_list|
      output_string += "#{record_list[0]} - #{record_list[1]} "
    end
    return output_string
  end

  def self.format_failed_records_list(list)
    if list.empty?
      return ""
    end
    output_string = "The following records and revision id\'s failed ingest due to pyCMR failure "
    list.each do |record_list|
      output_string += "#{record_list[0]} - #{record_list[1]} "
    end
    return output_string
  end

  def self.format_deleted_records_list(list)
    if list.empty?
      return ""
    end
    output_string = "The following records and revision id\'s are no longer in CMR."
    list.each do |record_list|
      output_string += "#{record_list[0]} - #{record_list[1]} "
    end
    return output_string
  end

  def self.api_url(data_type = "collections", format_type = "echo10", options = {})
    base_url = Cmr.get_cmr_base_url
    result = "#{base_url}/search/" + data_type + "." + format_type + "?"
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

  def self.total_collection_count(daac = nil, provider_list)
    if daac.nil?
      options = {'page_size' => 1}
      options['provider'] = provider_list
      url = Cmr.api_url('collections', 'echo10', options)
    else
      url = Cmr.api_url('collections', 'echo10', {'page_size' => 1,
                                                  'provider' => daac })
    end


    total_results = Cmr.cmr_request(url).parsed_response
    begin
      results_hash = Hash.from_xml(total_results)['results']
    rescue
      Rails.logger.error('CMR Connection Error: Collection Count')
      return 0
    end
    results_hash['hits'].to_i
  end


  def self.remove_header_values(collection_hash)
    #removes if it starts with xlmns or xsi
    collection_hash.delete_if { |key, value| (key.to_s.match(/^xmlns/)) || (key.to_s.match(/^xsi/)) }
    collection_hash
  end

  def self.get_cmr_base_url
    cmr_base_url = Rails.application.config.cmr_base_url
    if cmr_base_url.nil?
      cmr_base_url = 'https://cmr.earthdata.nasa.gov'
    end
    cmr_base_url
  end

  # returns [role, daac_name]
  def self.get_role_and_daac(uid, access_token)
    acl = AclDao.new(access_token, ENV['urs_client_id'], Cmr.get_cmr_base_url)
    role, daac = acl.get_role_and_daac(uid)
    [role, daac]
  end

  # returns the new [access_token, refresh_token]
  def self.refresh_access_token(current_user)
    begin
      conn = Faraday.new(:url => "#{ENV['urs_site']}") do |faraday|
        faraday.request :url_encoded # form-encode POST params
        faraday.headers['Authorization'] = 'Basic ' + ["#{ENV['urs_client_id']}:#{ENV['urs_client_secret']}"].pack('m0')
        faraday.response :logger # log requests to $stdout
        faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
      end
      response = conn.post "/oauth/token",
                           grant_type: "refresh_token",
                           refresh_token: current_user.refresh_token

      msg = "refresh_access_token - Calling external resource with "
      msg += "#{ENV['urs_site']}/oauth/token, status=#{response.status}, "
      msg += "contents=#{response.body}"
      Rails.logger.info(msg)

      json = JSON.parse(response.body)

      [json["access_token"], json["refresh_token"]]
    rescue => e
      message = "Error refreshing access token for #{current_user.uid}"
      Rails.logger.error( "refresh_access_token - #{message}, details=#{e.message}")
      [500, message]
    end
  end

  # returns [http status code, json body]
  def self.get_user_info(current_user)
    begin
      conn = Faraday.new(:url => "#{ENV['urs_site']}") do |faraday|
        faraday.request :url_encoded # form-encode POST params
        faraday.headers['Authorization'] = "Bearer #{current_user.access_token}"
        faraday.response :logger # log requests to $stdout
        faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
      end
      response = conn.get "/api/users/#{current_user.uid}",
                          calling_application: ENV['urs_client_id']

      msg = "get_user_info - Calling external resource with "
      msg += "#{ENV['urs_site']}/api/users/#{current_user.uid}, "
      msg += "status=#{response.status}, contents=#{response.body}"
      Rails.logger.info(msg)
      [response.status, JSON.parse(response.body)]
    rescue => e
      Rails.logger.error("get_user_info - Error retreiving user info from URS for #{current_user.uid}, message=#{e.message}");
    end
  end


end