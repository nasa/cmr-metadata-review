class Collection < ActiveRecord::Base
  has_many :records, :as => :recordable
  has_many :granules

  def self.all_records
    Record.all.where(recordable_type: "Collection")
  end

  def self.record_exists?(concept_id, revision_id) 
    return !(Collection.find_record(concept_id, revision_id).nil?)
  end

  def self.find_record(concept_id, revision_id) 
    record = nil

    collection = Collection.find_by concept_id: concept_id
    unless collection.nil?
      record = collection.records.where(revision_id: revision_id).first
    end

    return record
  end

  def self.assemble_new_record(concept_id, revision_id) 
    collection_data = Cmr.get_collection(concept_id)
    short_name = collection_data["ShortName"]
    ingest_time = DateTime.now

    #finding parent collection
    collection_object = Collection.find_or_create_by(concept_id: concept_id, short_name: short_name)
    #creating collection record related objects
    new_collection_record = Record.new(recordable: collection_object, revision_id: revision_id, closed: false)

    record_data = RecordData.new(datable: new_collection_record, rawJSON: collection_data.to_json)

    ingest_record = Ingest.new(record: new_collection_record, user: current_user, date_ingested: ingest_time)

    return collection_object, new_collection_record, record_data, ingest_record
  end

  def self.user_collection_ingests(user)
    CollectionRecord.find_by_sql("select * from collection_ingests inner join collection_records on collection_records.id = collection_ingests.collection_record_id where collection_ingests.user_id=#{user.id}")
  end

  def self.user_open_collection_reviews(user)
    user.collection_reviews.where(review_state: 0)
  end

  def self.user_available_collection_review(user)
    CollectionRecord.find_by_sql("with completed_reviews as (select * from collection_reviews where user_id=#{user.id} and review_state=1) select * from collection_records left outer join completed_reviews on collection_records.id = completed_reviews.collection_record_id where completed_reviews.collection_record_id is null")
  end

  def self.homepage_collection_search_results(provider, free_text, user)
    if free_text
      search_results = Curation.user_available_collection_review(user).select { |record| ((record.concept_id.include? free_text) || (record.short_name.include? free_text)) }
      unless provider.nil? || provider == ANY_KEYWORD
        search_results = search_results.select { |record| (record.concept_id.include? provider) }
      end
      search_results
    else
      []
    end
  end

end