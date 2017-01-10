class CollectionRecord < ActiveRecord::Base
  has_many :collection_flags
  has_one :collection_ingests
  has_many :collection_comments
  has_many :collection_reviews

  has_many :users, through: :collection_reviews   

  def self.ingested?(concept_id, revision_id)
    CollectionRecord.where(concept_id: concept_id, version_id: revision_id).any?
  end

  def self.ingest(concept_id)
    collection_data = Curation.collection_data(concept_id)
    already_ingested = CollectionRecord.ingested?(concept_id, revision_id)
    granule_results = Curation.granule_list_from_collection(concept_id)

    concept_id = collection_data["concept_id"]
    shortname = collection_data["Collection"]["ShortName"]
    version_id = collection_data["revision_id"]

    unless already_ingested
      record = CollectionRecord.new
      record.concept_id = concept_id
      record.short_name = shortname
      record.version_id = version_id
      record.closed = false
      record.rawJSON = collection_data.to_json
      record.save

      ingest_record = CollectionIngest.new
      ingest_record.collection_record_id = record.id
      ingest_record.user_id = current_user.id
      ingest_record.date_ingested = DateTime.now
      ingest_record.save

      if granule_results["hits"].to_i == 0
      else
      end

      return true
    else
      return false
    end 
  end

end
