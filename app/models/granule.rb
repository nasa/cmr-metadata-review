class Granule < Metadata
  has_many :records, as: :recordable, dependent: :destroy
  belongs_to :collection

  extend RecordRevision

  delegate :update?, :short_name, to: :collection

  # TODO: These granule ingest methods have a lot of similarities.  We should
  # figure out if there's some way to condense this code to make it easier to
  # maintain.
  def self.assemble_granule_components(concept_id, granules_count, collection_object, current_user)
    #returns a list of granule data
    granules_to_save = Cmr.random_granules_from_collection(concept_id, granules_count)
    #replacing the data with new granule & record & ingest objects
    granules_components = []

    granules_to_save.each do |granule_info|
      #creating the granule and related record
      Granule.transaction do
        granule = Granule.create(concept_id: granule_info['concept_id'], collection: collection_object)
        granule_object, granule_record, granule_record_data_list, granule_ingest = create_granule(granule, current_user, granule_info)
        granules_components.push([ granule_object, granule_record, granule_record_data_list, granule_ingest ])
      end
    end

    granules_components
  end

  # I don't like that this can return two different kinds of values.
  # It will return false if the concept id is a collection or if there is an error
  # Otherwise, will return the granule_record.   I think it should return nil and test for it.
  # This is only being used in the legacy ingest
  def self.add_granule_by_concept_id(collection_concept_id, granule_concept_id, current_user = User.find_by(role: "admin"))
    granule_info = Cmr.get_granule_with_collection_id(granule_concept_id)
    collection   = Collection.find_by(concept_id: collection_concept_id)

    return false unless collection
    Granule.transaction do
      granule = Granule.create(concept_id: granule_concept_id, collection: collection)
      create_granule(granule, current_user, granule_info)
    end
  rescue Cmr::CmrError
    false
  end

  # Fetches the latest revision for the granule, creates a review of it, then returns the granule record.
  def self.add_new_revision_to_granule(collection_concept_id, granule, current_user = User.find_by(role: "admin"))
    granule_info = Cmr.get_granule_with_collection_id(granule.concept_id)
    collection = Collection.find_by(concept_id: collection_concept_id)
    return nil unless collection
    create_granule(granule, current_user, granule_info)
  end

  def self.ingest_specific_granule(collection_concept_id, granule_concept_id, current_user = User.find_by(role: "admin"))
    granule_info = Cmr.get_granule_with_collection_id(granule_concept_id)
    collection = Collection.find_by(concept_id: collection_concept_id)

    if collection.nil?
      raise Cmr::CmrError.new, 'Collection record associated with granule could not be found in system.'
    end
    Granule.transaction do
      granule = Granule.create(concept_id: granule_concept_id, collection: collection)
      create_granule(granule, current_user, granule_info)
    end
  end

  def collection_concept_id
    collection.concept_id
  end

  def collection_short_name
    collection.short_name
  end

  def collection_name
  collection.long_name
  end

  private

  def self.create_granule(granule, current_user, granule_info)
    granule_record = Record.create(recordable: granule, revision_id: granule_info["revision_id"], daac: daac_from_concept_id(granule.concept_id), format: granule_info['format_type'])

    granule_record_data_list = []
    flattened_granule_data = Cmr.flatten_format_granule_data(granule_info["Granule"], granule_info['format_type'])

    #creating all the recordData values for the granule
    flattened_granule_data.each_with_index do |(key, value), i|
      granule_record_data = RecordData.new(record: granule_record)
      granule_record_data.last_updated = DateTime.now
      granule_record_data.column_name = key
      granule_record_data.value = value
      granule_record_data.order_count = i
      granule_record_data_list.push(granule_record_data)
    end
    granule_record.campaign = ApplicationController.helpers.clean_up_campaign(granule_record.campaign_from_record_data)
    granule_record.save

    ingest = Ingest.create(record: granule_record, user: current_user, date_ingested: DateTime.now)
    return granule, granule_record, granule_record_data_list, ingest
  end
end
