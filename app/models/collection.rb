# frozen_string_literal: true

class Collection < Metadata
  has_many :records, :as => :recordable
  has_many :granules

  SUPPORTED_FORMATS = ["dif10", "echo10", "umm_json"]
  INCLUDE_GRANULE_FORMATS = ["dif10", "echo10", "umm_json"]
  SHORT_NAMES = {
    "dif10" => "Entry_ID/Short_Name",
    "echo10" => "ShortName",
    "umm_json" => "ShortName"
  }

  extend RecordRevision

  scope :finished, -> {where(cmr_update: false)}

  # ====Params
  # string concept_id,
  # string revision_id
  # ====Returns
  # Boolean
  # ==== Method
  # Checks the DB and returns boolean if a record with matching concept_id and revision_id is found

  def self.record_exists?(concept_id, revision_id)
    record = Collection.find_record(concept_id, revision_id)
    record && !record.hidden?
  end

  def self.create_record(concept_id, revision_id, ingest_format, native_format, collection_data, options = {})
    return unless SUPPORTED_FORMATS.include?(ingest_format)

    short_name = collection_data[SHORT_NAMES[ingest_format]]

    Collection.transaction do
      collection = Collection.find_or_create_by(concept_id: concept_id)
      collection.update!(short_name: short_name)
      format_version = collection_data['__format_version']
      collection_data.delete("__format_version")

      new_record = Record.create(recordable: collection, revision_id: revision_id, format: ingest_format, format_version: format_version, native_format: native_format, daac: daac_from_concept_id(concept_id))

      collection_data.each_with_index do |(key, value), i|
        new_record.record_datas.create({
                                         last_updated: DateTime.now,
                                         column_name: key,
                                         value: value,
                                         order_count: i,
                                       })
      end
      new_record.campaign = ApplicationController.helpers.clean_up_campaign(new_record.campaign_from_record_data)
      new_record.save
      user = options[:user] || User.find_by(role: "admin")

      Ingest.create(record: new_record, user: user, date_ingested: DateTime.now)

      # In production there is an egress issue with certain link types given in metadata
      # AWS hangs requests that break ingress/egress rules.  Added this timeout to catch those
      Timeout::timeout(90) {new_record.create_script} if options[:run_script]

      collection.add_granule(user) if options[:add_granule]

      new_record
    end
  end

  def self.create_new_record(concept_id, revision_id, user, add_granule = false)
    native_format = Cmr.get_raw_collection_format(concept_id)

    # change this so it fetches the dif10 format instead, since dashboard doesn't support dif9
    native_format = native_format == 'dif' ? 'dif10' : native_format
    ingest_format = (native_format == 'iso19115' || native_format == 'iso-smap') ? 'umm_json' : native_format
    collection_data = Cmr.get_collection(concept_id, ingest_format)

    options = {
      add_granule: add_granule,
      run_script: true,
      user: user
    }
    create_record(concept_id, revision_id, ingest_format, native_format, collection_data, options)
    return [ingest_format, native_format]
  end

  def self.create_new_record_by_url(url, user = nil)
    concept_id, revision_id, data_format = parse_collection_url(url)

    # Change 'umm-json' to 'umm_json'
    data_format = data_format.underscore
    collection_data = Cmr.get_collection_by_url(url, data_format)
    create_record(concept_id, revision_id, data_format, collection_data, user: user)
  rescue Cmr::CmrError
    false
  end

  # returns concept_id, revision_id, data_format
  def self.parse_collection_url(url)
    cmr_base_url = Cmr.get_cmr_base_url
    regexp_str = "#{Regexp.escape(cmr_base_url)}(:443)?\\/search\\/concepts\\/(C\\d*-.*)\\/(\\d*)\\.(.*)"
    regexp = Regexp.new(regexp_str)
    match_data = regexp.match(url)
    match_data[2..4]
  end

  def update?
    self.cmr_update
  end

  def self.update?(concept_id)
    collection = Collection.find_by concept_id: concept_id
    if collection.nil?
      return false
    else
      collection.cmr_update
    end
  end

  #method added for the manual addition of granules into the database for collections.
  def add_granule(current_user)
    if current_user.nil?
      current_user = User.find_by(email: 'abaker@element84.com')
    end

    granules_components = []
    granules_count = 1
    native_format = self.records[0].format


    #only selecting granules for certain formats per business rules
    if Collection::INCLUDE_GRANULE_FORMATS.include? native_format
      #creating all the Granule related objects
      granules_components = Granule.assemble_granule_components(concept_id, granules_count, self, current_user)
    end

    #saving all the related collection and granule data in a combined transaction
    granules_components.flatten.each {|savable_object|
      if savable_object.is_a?(Array)
        savable_object.each do |savable_item|
          savable_item.save!
        end
      else
        savable_object.save!
      end
    }

    #In production there is an egress issue with certain link types given in metadata
    #AWS hangs requests that break ingress/egress rules.  Added this timeout to catch those
    Timeout::timeout(90) {
      #getting list of records for script
      granule_records = granules_components.flatten.select {|savable_object| savable_object.is_a?(Record)}
      granule_records.each do |record|
        record.create_script
      end
    }
  end

  def add_granule_with_concept_id(current_user, concept_id)
    if current_user.nil?
      current_user = User.find_by(email: 'abaker@element84.com')
    end

    granules_components = []
    granules_count = 1

    record = self.records[0]
    native_format = record.format

    #only selecting granules for certain formats per business rules
    if Collection::INCLUDE_GRANULE_FORMATS.include? native_format
      #creating all the Granule related objects
      granules_components = Granule.assemble_granule_components(concept_id, granules_count, self, current_user)
    end

    #saving all the related collection and granule data in a combined transaction
    granules_components.flatten.each {|savable_object|
      if savable_object.is_a?(Array)
        savable_object.each do |savable_item|
          savable_item.save!
        end
      else
        savable_object.save!
      end
    }


    #In production there is an egress issue with certain link types given in metadata
    #AWS hangs requests that break ingress/egress rules.  Added this timeout to catch those
    Timeout::timeout(20) {
      #getting list of records for script
      granule_records = granules_components.flatten.select {|savable_object| savable_object.is_a?(Record)}
      granule_records.each do |record|
        record.create_script
      end

    }
    return granules_components.flatten[0] # returns the granule object
  end


  def refresh!(current_user)
    latest_revision = Cmr.current_revision_for(concept_id)

    if Collection.record_exists?(concept_id, latest_revision)
      false
    else
      Collection.create_new_record(concept_id, latest_revision, current_user)
    end
  end

  def finish!
    update_attributes(cmr_update: false) if all_records_finished?
  end

  def allow_updates!
    update_attributes(cmr_update: true) unless update?
  end

  def long_name
    records.last.long_name
  end

  private

  def all_records_finished?
    records.visible.all? {|r| r.state == Record::STATE_FINISHED.to_s}
  end
end
