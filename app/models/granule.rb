class Granule < ActiveRecord::Base
  has_many :records, as: :recordable, dependent: :destroy
  belongs_to :collection

  extend Modules::RecordRevision

  delegate :update?, :short_name, to: :collection
  
  def get_records
    self.records.where.not(state: Record::STATE_HIDDEN)
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
end
