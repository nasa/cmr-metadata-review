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



  # ====Params   
  # String, name of provider     
  # ====Returns
  # Float Array
  # ==== Method
  # First assembles array of all records marked closed
  # For each record, calculates the amount of red colored columns as a % of total columns

  def self.quality_done_records(daac_short_name = nil)
    if daac_short_name.nil?
      collection_records = Collection.all_records
    else 
      collections = Collection.by_daac(daac_short_name)
      collection_ids = collections.map {|collection| collection.id }
      collection_records = Record.all.select { |record| record.recordable_type == "Collection" && record.closed && (collection_ids.include? record.recordable_id) }
    end

    record_data_sets = collection_records.map { |record|  record.record_datas }
    scores = record_data_sets.map { |data_list| (1 - (data_list.select { |data| data.color == "red" }).count.to_f / (data_list.select { |data| data.color != "" }).count) * 100 }
    scores
  end

  # ====Params   
  # String, name of provider     
  # ====Returns
  # Integer
  # ==== Method
  # Obtains the ordered revisions list of lists
  # Iterates through the list summing the count of sublists where the first record is done and there is at least a second revision marked done

  def self.updated_done_count(daac_short_name = nil)
    ordered_revisions = Collection.ordered_revisions(daac_short_name).values
    updated_and_done = ordered_revisions.select { |record_list|
      record_list[0].closed && ((record_list.select { |record| record.closed }).count > 1)
    }

    updated_and_done.count
  end

  # ====Params   
  # String, name of provider     
  # ====Returns
  # Integer
  # ==== Method
  # Obtains the ordered revisions list of lists
  # Iterates through the list summing count of sublists where there is a revision beyond the original one that is marked done.

  def self.updated_count(daac_short_name = nil)
    ordered_revisions = Collection.ordered_revisions(daac_short_name).values
    updated = ordered_revisions.select { |record_list|
      record_list.drop(1).count > 0
    }

    updated.count
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
  # None    
  # ====Returns
  # Integer
  # ==== Method
  # Aggregates the total number of Collections with their most recent revision_id record in a completed state.

  def self.total_completed(daac_short_name = nil)
    if daac_short_name.nil?
      newest_record_list = Collection.all_newest_revisions
    else
      newest_record_list = Collection.all_newest_revisions(daac_short_name)
    end
    (newest_record_list.select {|record| record.closed == true }).count
  end 

  # ====Params   
  # None    
  # ====Returns
  # Integer
  # ==== Method
  # Aggregates the total number of Collections with their most recent revision_id record in the in process state.

  def self.total_in_process
    newest_record_list = Collection.all_newest_revisions
    (newest_record_list.select {|record| record.closed == false }).count
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

  # ====Params   
  # String, DAAC Short Name  
  # ====Returns
  # Hash of {record id's => completed review counts}
  # ==== Method
  # Takes all of the newest revisions for entire system or by DAAC
  # Then creates a hash of each collection and the corresponding counts of completed reviews

  def self.completed_review_counts(daac_short_name = nil)
    if daac_short_name.nil?
      newest_records = Collection.all_newest_revisions
    else 
      newest_records = Collection.all_newest_revisions(daac_short_name)
    end

    review_hash = {}
    completed_reviews = Review.all.where(review_state: 1)  
    #setting up review count hash
    newest_records.each do |record|
      review_hash[record.id] = 0
    end

    completed_reviews.each do |review|
      if review_hash.key?(review.record_id)
        review_hash[review.record_id] = review_hash[review.record_id] + 1
      end
    end

    review_hash.values
  end  

  # ====Params   
  # String, DAAC Short Name  
  # ====Returns
  # List of 4 Integers representing flags
  # ==== Method
  # First the method gets a list of all newest revision records, then finds all RecordData that corresponds to any record in the list
  # Then aggregates the counts of each flag type and returns a list of those values

  def self.color_counts(daac_short_name = nil)
    newest_revisions = Collection.all_newest_revisions(daac_short_name)
    record_ids = newest_revisions.map { |record| record.id }
    record_datas = RecordData.all.select { |data| record_ids.include? data.record_id }
    
    blue_count = (record_datas.select { |data| data.color == "blue"}).count
    green_count = (record_datas.select { |data| data.color == "green"}).count
    yellow_count = (record_datas.select { |data| data.color == "yellow"}).count
    red_count = (record_datas.select { |data| data.color == "red"}).count

    [blue_count, green_count, yellow_count, red_count]
  end

  # ====Params   
  # String, DAAC Short Name  
  # ====Returns
  # Hash of counts for each flag type
  # ==== Method
  # Obtains the complete set of RecordData elements related to the newest revision of each collection
  # Iterates through that list summing for each flag the number of times a recorddata has that flag and is marked red

  def self.red_flags(daac_short_name = nil)
    newest_revisions = Collection.all_newest_revisions(daac_short_name)
    record_ids = newest_revisions.map { |record| record.id }
    record_datas = RecordData.all.select { |data| record_ids.include? data.record_id }

    flagged_data = record_datas.select { |data| !data.flag.empty? && (data.color == "red") }

    flag_hash = { "Accessibility" => 0, "Traceability" => 0, "Usability" => 0 }
    flagged_data.each do |data|
      data.flag.each do |flag_name|
        flag_hash[flag_name] = flag_hash[flag_name] + 1
      end
    end

    flag_hash
  end


end