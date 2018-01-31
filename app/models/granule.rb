class Granule < ActiveRecord::Base
  has_many :records, :as => :recordable
  belongs_to :collection

  extend Modules::RecordRevision


  def get_records
    self.records.where.not(state: Record::STATE_HIDDEN)
  end

  # ====Params
  # string concept_id,
  # string revision_id
  # ====Returns
  # Boolean
  # ==== Method
  # Checks the DB and returns boolean if a record with matching concept_id is found

  def self.record_exists?(concept_id, revision_id)
    record = Collection.find_record(concept_id, revision_id)
    return (!record.nil?) && (!record.hidden?)
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
        granule_record_data.daac = granule_data["concept_id"].partition('-').last
        granule_record_data_list.push(granule_record_data)
      end

      granule_ingest = Ingest.new(record: new_granule_record, user: current_user, date_ingested: DateTime.now)
      #pushing the list of granule parts into the granule_components list for a return value
      granules_components.push([ granule_object, new_granule_record, granule_record_data_list, granule_ingest ])
    end

    granules_components
  end

  def self.assemble_new_record(concept_id, revision_id, current_user)
    native_format = Cmr.get_raw_record_format(concept_id, "granules")

    if native_format == "dif10"
      granule_data = Cmr.get_granule(concept_id)
      short_name = granule_data["Entry_ID/Short_Name"]
    elsif native_format == "echo10"
      granule_data = Cmr.get_granule(concept_id)
      short_name = granule_data["ShortName"]
    else
      #Guard against records that come in with unsupported types
      return
    end

    ingest_time = DateTime.now
    #finding parent collection
    granule_object = Granule.find_or_create_by(concept_id: concept_id)
    granule_object.short_name = short_name
    granule_object.save!
    #creating collection record related objects
    new_granule_record = Record.new(recordable: granule_object, revision_id: revision_id, format: native_format)

    record_data_list = []

    granule_data.each_with_index do |(key, value), i|
      record_data = RecordData.new(record: new_granule_record)
      record_data.last_updated = DateTime.now
      record_data.column_name = key
      record_data.value = value
      record_data.order_count = i
      record_data.daac = concept_id.partition('-').last
      record_data_list.push(record_data)
    end

    ingest_record = Ingest.new(record: new_granule_record, user: current_user, date_ingested: ingest_time)

    return granule_object, new_granule_record, record_data_list, ingest_record
  end


  def update?
    self.collection.update?
  end

  def short_name
    self.collection.short_name
  end

  def delete_self
    granule = self
    granule_records = granule.records
    granule_records.each do |record|
      record_datas = record.record_datas
      record_datas.each do |data|
        data.destroy
      end
      if record.try(:ingest)
        record.ingest.destroy
      end
      record.destroy
    end
    granule.destroy
  end
end
