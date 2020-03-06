module RecordRevision

  # ====Params
  # String, DAAC Short Name
  # ====Returns
  # Collection list
  # ==== Method
  # returns all collections ingested that belong to the daac parameter

  def by_daac(daac_short_name)
    records = Record.daac(daac_short_name)
    self.joins(:records).merge(records)
  end

  # ====Params
  # string concept_id,
  # string revision_id
  # ====Returns
  # Record || nil
  # ==== Method
  # Queries the DB and returns a record matching params
  # if no record is found, returns nil.

  def find_record(concept_id, revision_id)
    record = nil

    collection = self.find_by concept_id: concept_id
    unless collection.nil?
      record = collection.records.where(revision_id: revision_id).where.not(state: Record::STATE_HIDDEN).first
    end

    return record
  end

  # ====Params
  # string concept_id,
  # ====Returns
  # data_type || nil
  # ==== Method
  # Checks if the data type is a collection or granule based on concept id
  # will return nil if no concept id is provided
  def find_type(concept_id)
    type = nil

    if !concept_id.eql? ""
      if concept_id[0].downcase.eql? "c"
        type = Collection
      elsif concept_id[0].downcase.eql? "g"
        type = Granule
      end
    end
  end

  # ====Params
  # Optional String DAAC short name
  # ====Returns
  # Record Array
  # ==== Method
  # Queries all records of the param type from DB
  # Then filters them to return a list of only the newest revision id for each collection in the system or by DAAC.

  def all_newest_revisions(daac_short_name = nil, application_mode = :arc_mode)
    all_revisions = self.ordered_revisions(daac_short_name, application_mode)
    record_lists = all_revisions.values
    newest_records = record_lists.map { |record_list| record_list[0] }
    newest_records
  end

  # ====Params
  # String, name of provider
  # ====Returns
  # List of record lists, each sub list is all records for a collection in order of ingest
  # ==== Method
  # Grabs all records, then maps them to the sublists based on collection id
  # Sorts the sublists based on record id with the assumption that newer revisions are ingested after older ones.
  # Do not want to rely on revision ids since they may not be numbers

  def ordered_revisions(daac_short_name = nil, application_mode = :arc_mode)
    collection_records = all_records(application_mode).where(state: MetricData::METRIC_STATES)

    collection_records = collection_records.daac(daac_short_name) if daac_short_name

    records_hash = {}

    collection_records.each do |record|
      if records_hash.key?(record.recordable_id)
        records_hash[record.recordable_id].push(record)
      else
        records_hash[record.recordable_id] = [record]
      end
    end

    records_hash.each do |key, list|
      records_hash[key] = list.sort { |x,y| y.id.to_i <=> x.id.to_i }
    end

    records_hash
  end

  # ====Params
  # None
  # ====Returns
  # Record Array
  # ==== Method
  # returns all records found in the DB of type collection

  def all_records(application_mode)
    Record.all_records(application_mode).where(recordable_type: name).visible
  end


end
