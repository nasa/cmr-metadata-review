class Granule < ActiveRecord::Base
  has_many :records, as: :recordable, dependent: :destroy
  belongs_to :collection

  extend RecordRevision

  delegate :update?, :short_name, to: :collection

  def get_records
    records.visible
  end

  def self.assemble_granule_components(concept_id, granules_count, collection_object, current_user)
    #returns a list of granule data
    granules_to_save = Cmr.random_granules_from_collection(concept_id, granules_count)
    #replacing the data with new granule & record & ingest objects
    granules_components = []

    granules_to_save.each do |granule_data|
      #creating the granule and related record
      granule_object = Granule.new(concept_id: granule_data["concept_id"], collection: collection_object)
      new_granule_record = Record.new(recordable: granule_object, revision_id: granule_data["revision_id"])
      new_granule_record.save

      granule_record_data_list = []

      flattened_granule_data = Cmr.get_granule(granule_data['concept_id'])

      #creating all the recordData values for the granule
      flattened_granule_data.each_with_index do |(key, value), i|
        granule_record_data = RecordData.new(record: new_granule_record)
        granule_record_data.last_updated = DateTime.now
        granule_record_data.column_name = key
        granule_record_data.value = value
        granule_record_data.order_count = i
        granule_record_data.daac = daac_from_concept_id(granule_data["concept_id"])
        granule_record_data_list.push(granule_record_data)
      end

      granule_ingest = Ingest.new(record: new_granule_record, user: current_user, date_ingested: DateTime.now)
      #pushing the list of granule parts into the granule_components list for a return value
      granules_components.push([ granule_object, new_granule_record, granule_record_data_list, granule_ingest ])
    end

    granules_components
  end

  def self.add_granule_by_concept_id(granule_concept_id, current_user = User.find_by(role: "admin"))
    granule_info = Cmr.get_granule_with_collection_data(granule_concept_id)
    collection   = Collection.find_by(concept_id: granule_info["collection_concept_id"])

    return false unless collection

    granule_data = granule_info["Granule"]

    Granule.transaction do
      granule        = Granule.create(concept_id: granule_concept_id, collection: collection)
      granule_record = Record.create(recordable: granule, revision_id: granule_info["revision_id"])

      granule_data.each_with_index do |(key, value), i|
        granule_record.record_datas.create(
          last_updated: DateTime.now,
          column_name:  key,
          value:        value,
          order_count:  i,
          daac:         daac_from_concept_id(granule_concept_id)
        )
      end

      Ingest.create(record: granule_record, user: current_user, date_ingested: DateTime.now)
      granule_record
    end
  rescue Cmr::CmrError
    false
  end

  # Adds a new granule revision record to the specified granule
  def self.add_new_revision_to_granule(granule, current_user = User.find_by(role: "admin"))
    granule_info = Cmr.get_granule_with_collection_data(granule.concept_id)
    collection   = Collection.find_by(concept_id: granule_info["collection_concept_id"])

    return false unless collection

    granule_data = granule_info["Granule"]

    Granule.transaction do
      granule_record = Record.create(recordable: granule, revision_id: granule_info["revision_id"])

      granule_data.each_with_index do |(key, value), i|
        granule_record.record_datas.create(
          last_updated: DateTime.now,
          column_name:  key,
          value:        value,
          order_count:  i,
          daac:         daac_from_concept_id(granule.concept_id)
        )
        granule_record.save!
      end


      granule_ingest = Ingest.create(record: granule_record, user: current_user, date_ingested: DateTime.now)
      granule_ingest.save!
      granule.save!
      true
    end
  rescue Cmr::CmrError
    false
  end

  def self.daac_from_concept_id(concept_id)
    concept_id.partition('-').last
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
end
