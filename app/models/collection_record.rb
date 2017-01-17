class CollectionRecord < ActiveRecord::Base
  include RecordHelper

  has_many :flags, as: :flagable
  has_one :ingest, as: :ingestable
  has_many :comments, as: :commentable
  has_many :reviews, as: :reviewable

  # has_many :users, through: :collection_reviews   

  def self.ingested?(concept_id, revision_id)
    CollectionRecord.where(concept_id: concept_id, version_id: revision_id).any?
  end

  def self.save_granules(concept_id, shortname, version_id, granule_count, user)
    if granule_count == 0
      #no actions needed
      return true
    else
      granule_results = Curation.granule_list_from_collection(concept_id)
      total_granules = granule_results["hits"].to_i
        
      #checking if we asked for more granules than exist  
      if total_granules < granule_count
        return false
      end
      #the scheme here is as follows
      #1. get a random array of nums and pull granules from those positions out of cmr
      #2. make a collection of granule objects ready to be saved with the info
      #3. roll through and save them all, reversing all preceding saves if there is an error

      granule_data_list = []
      granule_object_list = []
      granule_ingest_list = []

      begin
        #getting a random list of granules addresses within available amount
        granules_picked = (0...total_granules).to_a.shuffle.take(granule_count)
        granules_picked.each do |granule_address|
          #have to add 1 because cmr pages are 1 indexed
          page_num = (granule_address / 10) + 1
          page_item = granule_address % 10

          #cmr does not return a list if only one result
          if total_granules > 1
            granule_data = Curation.granule_list_from_collection(concept_id, page_num)["result"][page_item]
          else
            granule_data = Curation.granule_list_from_collection(concept_id, page_num)["result"]
          end
          granule_data_list.push(granule_data)
        end

        granule_data_list.each do |granule_data_item|
          granule_record = GranuleRecord.new
          granule_record.granule_ur = granule_data_item["concept_id"]
          granule_record.version_id = granule_data_item["revision_id"]
          granule_record.collection_concept_id = granule_data_item["collection_concept_id"]
          granule_record.closed = false
          granule_record.rawJSON = granule_data_item.to_json
          granule_object_list.push(granule_record)
        end

        granule_object_list.each do |granule_object|
          granule_object.save!

          granule_ingest_record = Ingest.new
          granule_ingest_record.ingestable = granule_object
          granule_ingest_record.user_id = user.id
          granule_ingest_record.date_ingested = DateTime.now
          granule_ingest_list.push(granule_ingest_record)
        end

        granule_ingest_list.each do |granule_ingest|
          granule_ingest.save!
        end
      rescue 
        #deleting all granule records
        if granule_object_list
          granule_object_list.each do |granule_object|
            granule_object.destroy
          end
        end
        if granule_ingest_list
          granule_ingest_list.each do |granule_ingest|
            granule_ingest.destroy
          end
        end
        return false
      end

      return true  
    end
  end

  def self.save_collection_with_granules(concept_id, version_id, collection_data, granule_count, user)
    begin
      shortname = collection_data["Collection"]["ShortName"]

      record = CollectionRecord.new
      record.concept_id = concept_id
      record.short_name = shortname
      record.version_id = version_id
      record.closed = false
      record.rawJSON = collection_data.to_json
      record.save!

      ingest_record = Ingest.new
      ingest_record.ingestable = record
      ingest_record.user_id = user.id
      ingest_record.date_ingested = DateTime.now
      ingest_record.save!

      if !(CollectionRecord.save_granules(concept_id, shortname, version_id, granule_count, user))
        #deleting the records
        record.destroy
        ingest_record.destroy
        return false
      end
    rescue 
      record.destroy if record 
      ingest_record.destroy if ingest_record
      return false
    end

    return true
  end

  def self.ingest_with_granules(concept_id, revision_id, granule_count, user)
    collection_data = Cmr.get_collection(concept_id)
    already_ingested = CollectionRecord.ingested?(concept_id, revision_id)

    unless already_ingested
      #nil gets turned into 0
      granule_count = granule_count.to_i
      return CollectionRecord.save_collection_with_granules(concept_id, revision_id, collection_data, granule_count, user)
    else
      return false
    end 
  end

  def add_comment(user)
  #   create_table "collection_comments", force: :cascade do |t|
  #   t.integer "collection_record_id"
  #   t.integer "user_id"
  #   t.integer "total_comment_count"
  #   t.string  "rawJSON"
  # end
    new_comment = Comment.new
    new_comment.commentable = self
    new_comment.user = user
    new_comment.total_comment_count = 0
    new_comment.rawJSON = self.new_comment_JSON
    new_comment.save!
  end

  def add_script_comment(script_JSON)
    new_comment = Comment.new
    new_comment.commentable = self
    new_comment.user_id = -1
    new_comment.total_comment_count = 0
    new_comment.rawJSON = script_JSON
    new_comment.save!
  end

  def new_comment_JSON
    record_hash = JSON.parse(self.rawJSON)
    empty_hash = empty_contents(record_hash)
    empty_hash.to_json
  end

  def evaluate_script
    begin
      script_results = CollectionScript.run_script(self)
      self.add_script_comment(script_results)
    rescue
      return false
    end

    return true
  end

end
