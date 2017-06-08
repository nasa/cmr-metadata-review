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
    Record.all.where(recordable_type: "Collection")
  end

  # ====Params   
  # string concept_id,     
  # string revision_id
  # ====Returns
  # Boolean
  # ==== Method
  # Checks the DB and returns boolean if a record with matching concept_id and revision_id is found

  def self.record_exists?(concept_id, revision_id) 
    return !(Collection.find_record(concept_id, revision_id).nil?)
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
      record = collection.records.where(revision_id: revision_id).first
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
      collection_records = Collection.all_records
    else 
      collections = Collection.by_daac(daac_short_name)
      collection_ids = collections.map {|collection| collection.id }
      collection_records = Record.all.select { |record| record.recordable_type == "Collection" && (collection_ids.include? record.recordable_id) }
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
    Collection.all.select { |collection| collection.concept_id.include? daac_short_name }
  end



end