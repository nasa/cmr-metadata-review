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

  # ====Params   
  # Optional String DAAC short name
  # ====Returns
  # Record Array 
  # ==== Method
  # Queries all records of the param type from DB
  # Then filters them to return a list of only the newest revision id for each collection in the system or by DAAC.

  def self.all_newest_revisions(daac_short_name = nil)
    if daac_short_name.nil?
      collection_records = Collection.all_records
    else 
      collections = Collection.by_daac(daac_short_name)
      collection_ids = collections.map {|collection| collection.id }
      collection_records = Record.all.select { |record| record.recordable_type == "Collection" && (collection_ids.include? record.recordable_id) }
    end
    newest_records = {}

    collection_records.each do |record|
      if newest_records.key?(record.recordable_id)
        revision_id = newest_records[record.recordable_id].revision_id.to_i
        new_revision_id = record.revision_id.to_i
        #for each collection id, checking if record is a newer revision
        if new_revision_id > revision_id
          newest_records[record.recordable_id] = record
        end
      else
        newest_records[record.recordable_id] = record
      end
    end

    newest_records.values
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



  def self.colors_hash(daac_short_name = nil)
    newest_revisions = Collection.all_newest_revisions(daac_short_name)

    record_ids = newest_revisions.map { |record| record.id }
    colors = Color.all

    color_hash = {}
    colors.each do |color|
      if record_ids.include? color.record_id
        color_hash[color.record_id] = [color.blue_count, color.green_count, color.yellow_count, color.red_count]
      end
    end

    color_hash.values
  end

  def self.color_counts(daac_short_name = nil)
    color_hash = Collection.colors_hash(daac_short_name)
    reducedColors = color_hash.reduce([0,0,0,0]) { |countArr, singleArr| [countArr[0] + singleArr[0], countArr[1] + singleArr[1], countArr[2] + singleArr[2], countArr[3] + singleArr[3]] }
    reducedColors
  end

end