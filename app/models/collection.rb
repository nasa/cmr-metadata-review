class Collection < ActiveRecord::Base
  has_many :records, :as => :recordable
  has_many :granules

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
    collection_data = Cmr.get_collection(concept_id)
    short_name = collection_data["ShortName"]
    ingest_time = DateTime.now
    #finding parent collection
    collection_object = Collection.find_or_create_by(concept_id: concept_id)
    collection_object.short_name = short_name
    collection_object.save
    #creating collection record related objects
    new_collection_record = Record.new(recordable: collection_object, revision_id: revision_id, closed: false)

    record_data_list = []

    collection_data.each do |key, value|
      record_data = RecordData.new(record: new_collection_record)
      record_data.last_updated = DateTime.now
      record_data.column_name = key
      record_data.value = value
      record_data.daac = concept_id.partition('-').last
      record_data_list.push(record_data)
    end

    ingest_record = Ingest.new(record: new_collection_record, user: current_user, date_ingested: ingest_time)

    return collection_object, new_collection_record, record_data_list, ingest_record
  end

  def self.user_collection_ingests(user)
    CollectionRecord.find_by_sql("select * from collection_ingests inner join collection_records on collection_records.id = collection_ingests.collection_record_id where collection_ingests.user_id=#{user.id}")
  end

  # ====Params   
  # User     
  # ====Returns
  # Review Array
  # ==== Method
  # Queries the DB and returns all reviews belonging to param User which   
  # are marked in progress.  In progress determined by "review_state" field being == to 0    

  def self.user_open_collection_reviews(user)
    user.collection_reviews.where(review_state: 0)
  end

end