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

  def self.quality_done_records(daac_short_name = nil)
    if daac_short_name.nil?
      collection_records = Collection.all_records
    else 
      collections = Collection.by_daac(daac_short_name)
      collection_ids = collections.map {|collection| collection.id }
      collection_records = Record.all.select { |record| record.recordable_type == "Collection" && record.closed && (collection_ids.include? record.recordable_id) }
    end

    record_data_sets = collection_records.map { |record|  record.record_datas }
    scores = record_data_sets.map { |data_list| (data_list.select { |data| data.color == "red" }).count.to_f / (data_list.select { |data| data.color != "" }).count * 100 }
    scores
  end


  def self.updated_done_count(daac_short_name = nil)
    ordered_revisions = Collection.ordered_revisions(daac_short_name)
    updated_and_done = ordered_revisions.select { |record_list|
      record_list[0].closed && ((record_list.select { |record| record.closed }).count > 1)
    }

    updated_and_done.count
  end

  def self.updated_count(daac_short_name = nil)
    ordered_revisions = Collection.ordered_revisions(daac_short_name)
    updated = ordered_revisions.select { |record_list|
      ((record_list.drop(1).select { |record| record.closed }).count > 0)
    }

    updated.count
  end

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
      records_hash[key] = list.sort { |x,y| y.recordable_id.to_i <=> x.recordable_id.to_i } 
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

  def self.red_flags(daac_short_name = nil)
    newest_revisions = Collection.all_newest_revisions(daac_short_name)
    record_ids = newest_revisions.map { |record| record.id }
    record_datas = RecordData.all.select { |data| record_ids.include? data.record_id }

    flagged_data = RecordData.all.select { |data| record_ids.includ? data.record_id && !data.flag.empty? && (data.color == "red") }

    flag_hash = { "Accessibility" => 0, "Traceability" => 0, "Usability" => 0 }
    flagged_data.each do |data|
      data.flag.each do |flag_name|
        flag_hash[flag_name] = flag_hash[flag_name] + 1
      end
    end

    flag_hash
  end


end