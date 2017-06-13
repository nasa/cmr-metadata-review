class Collection < ActiveRecord::Base
  has_many :records, :as => :recordable
  has_many :granules

  SUPPORTED_FORMATS = ["dif10", "echo10"]
  INCLUDE_GRANULE_FORMATS = ["echo10"]

  # ====Params   
  # None
  # ====Returns
  # Record Array
  # ==== Method
  # returns all records found in the DB of type collection

  def self.all_records
    Record.all.where(recordable_type: "Collection", hidden: false)
  end

  # ====Params   
  # string concept_id,     
  # string revision_id
  # ====Returns
  # Boolean
  # ==== Method
  # Checks the DB and returns boolean if a record with matching concept_id and revision_id is found

  def self.record_exists?(concept_id, revision_id) 
    record = Collection.find_record(concept_id, revision_id)
    return (!record.nil?) && (!record.hidden)
  end

  # ====Params   
  # string concept_id,     
  # string revision_id
  # ====Returns
  # Record || nil
  # ==== Method
  # Queries the DB and returns a record matching params    
  # if no record is found, returns nil.

  def self.find_record(concept_id, revision_id) 
    record = nil

    collection = Collection.find_by concept_id: concept_id
    unless collection.nil?
      record = collection.records.where(revision_id: revision_id, hidden: false).first
    end

    return record
  end



  def self.assemble_new_record(concept_id, revision_id, current_user)
    native_format = Cmr.get_raw_collection_format(concept_id)

    if native_format == "dif10"
      collection_data = Cmr.get_collection(concept_id, native_format)
      short_name = collection_data["Entry_ID/Short_Name"]
    elsif native_format == "echo10"
      collection_data = Cmr.get_collection(concept_id, native_format)
      short_name = collection_data["ShortName"]
    else 
      #Guard against records that come in with unsupported types
      return
    end

    ingest_time = DateTime.now
    #finding parent collection
    collection_object = Collection.find_or_create_by(concept_id: concept_id)
    collection_object.short_name = short_name
    collection_object.save!
    #creating collection record related objects
    new_collection_record = Record.new(recordable: collection_object, revision_id: revision_id, format: native_format, closed: false)

    record_data_list = []

    collection_data.each_with_index do |(key, value), i|
      record_data = RecordData.new(record: new_collection_record)
      record_data.last_updated = DateTime.now
      record_data.column_name = key
      record_data.value = value
      record_data.order_count = i
      record_data.daac = concept_id.partition('-').last
      record_data_list.push(record_data)
    end

    ingest_record = Ingest.new(record: new_collection_record, user: current_user, date_ingested: ingest_time)

    return collection_object, new_collection_record, record_data_list, ingest_record
  end

  # ====Params   
  # String, name of provider     
  # ====Returns
  # List of record lists, each sub list is all records for a collection in order of ingest
  # ==== Method
  # Grabs all records, then maps them to the sublists based on collection id
  # Sorts the sublists based on record id with the assumption that newer revisions are ingested after older ones.
  # Do not want to rely on revision ids since they may not be numbers


  def self.ordered_revisions(daac_short_name = nil)
    if daac_short_name.nil?
      collection_records = Collection.all_records.where(closed: true)
    else 
      collections = Collection.by_daac(daac_short_name)
      collection_ids = collections.map {|collection| collection.id }
      collection_records = Record.all.select { |record| record.closed && (record.recordable_type == "Collection") && (collection_ids.include? record.recordable_id) }
    end
    records_hash = {}

    collection_records.each do |record|
      if records_hash.key?(record.recordable_id)
        records_hash[record.recordable_id].push(record)
      else
        records_hash[record.recordable_id] = [record]
      end
    end

    records_hash.each do |key, list|
      records_hash[key] = list.sort { |x,y| y.id.to_i <=> x.id.to_i } 
    end

    records_hash
  end

  # ====Params   
  # Optional String DAAC short name
  # ====Returns
  # Record Array 
  # ==== Method
  # Queries all records of the param type from DB
  # Then filters them to return a list of only the newest revision id for each collection in the system or by DAAC.

  def self.all_newest_revisions(daac_short_name = nil)
    all_revisions = self.ordered_revisions(daac_short_name)
    record_lists = all_revisions.values
    newest_records = record_lists.map { |record_list| record_list[0] }
    newest_records
  end

  # ====Params   
  # String, DAAC Short Name  
  # ====Returns
  # Collection list
  # ==== Method
  # returns all collections ingested that belong to the daac parameter

  def self.by_daac(daac_short_name)
    Collection.all.select { |collection| (collection.concept_id.include? daac_short_name) && (!collection.get_records.empty?)}
  end

  def get_records
    self.records.where(hidden: false)
  end


  #helper method to force in old records
  #only should be used from the console
  def self.ingest_old_revision(concept_id, revision_id, collectionFormat)
    #guard against creating a duplicate record
    if Collection.record_exists?(concept_id, revision_id)
      return
    end

    url = "https://cmr.earthdata.nasa.gov/search/collections?concept_id=#{concept_id}&all_revisions=true&pretty=true"
    resp = Cmr.cmr_request(url).parsed_response
    data_sets = resp["results"]["references"]["reference"]

    found_revision = data_sets.select {|data| data["revision_id"] == revision_id}
    revision_url = found_revision[0]["location"]
    formatted_url = revision_url + "." + collectionFormat

    collection_xml = Cmr.cmr_request(formatted_url).parsed_response
    collection_results = Hash.from_xml(collection_xml)["Collection"]
    collection_results = Cmr.flatten_collection(collection_results)

    begin
      #guard against bringing in an unsupported format
      native_format = Cmr.get_raw_collection_format(concept_id)
      if !(Collection::SUPPORTED_FORMATS.include? native_format) 
        redirect_to home_path
        flash[:alert] = "The system could not ingest the selected record, #{native_format} format records are not currently supported"
        return
      end

      #creating all the collection related objects
      collection_object, new_collection_record, record_data_list, ingest_record = Collection.assemble_old_record(concept_id, revision_id, collection_results)

      #saving all the related collection and granule data in a combined transaction
      ActiveRecord::Base.transaction do
        new_collection_record.save!
        record_data_list.each do |record_data|
          record_data.save!
        end
        ingest_record.save!
      end
    end
  end

  def self.assemble_old_record(concept_id, revision_id, collection_data)
    native_format = Cmr.get_raw_collection_format(concept_id)

    if native_format == "dif10"
      short_name = collection_data["Entry_ID/Short_Name"]
    elsif native_format == "echo10"
      short_name = collection_data["ShortName"]
    else 
      #Guard against records that come in with unsupported types
      return
    end

    ingest_time = DateTime.now
    #finding parent collection
    collection_object = Collection.find_or_create_by(concept_id: concept_id)
    collection_object.short_name = short_name
    collection_object.save!
    #creating collection record related objects
    new_collection_record = Record.new(recordable: collection_object, revision_id: revision_id, format: native_format, closed: false)

    record_data_list = []

    collection_data.each_with_index do |(key, value), i|
      record_data = RecordData.new(record: new_collection_record)
      record_data.last_updated = DateTime.now
      record_data.column_name = key
      record_data.value = value
      record_data.order_count = i
      record_data.daac = concept_id.partition('-').last
      record_data_list.push(record_data)
    end

    ingest_record = Ingest.new(record: new_collection_record, user: (User.find_by id: 1), date_ingested: ingest_time)

    return collection_object, new_collection_record, record_data_list, ingest_record

  end  

end