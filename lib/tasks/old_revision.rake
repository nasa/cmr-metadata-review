# These methods are rough copies of the normal ingest methods, but wired to ingest an old revision

# can be run with command like 
# rake old_revision[C10884-GHRC,32,echo10]

# note, no whitespace in params list, whitespace will break rake params


task :old_revision, [:concept_id, :revision_id, :collectionFormat]  => :environment do |task, args|

  def ingest_old_revision(concept_id, revision_id, collectionFormat)
    #guard against creating a duplicate record
    if Collection.record_exists?(concept_id, revision_id)
      return
    end

    #getting old revision
    url = "https://cmr.earthdata.nasa.gov/search/collections?concept_id=#{concept_id}&all_revisions=true&pretty=true"
    resp = Cmr.cmr_request(url).parsed_response
    data_sets = resp["results"]["references"]["reference"]

    found_revision = data_sets.select {|data| data["revision_id"] == revision_id}
    revision_url = found_revision[0]["location"]
    formatted_url = revision_url + "." + collectionFormat

    collection_xml = Cmr.cmr_request(formatted_url).parsed_response
    collection_results = Hash.from_xml(collection_xml)["Collection"]
    collection_results = Cmr.flatten_collection(collection_results)

    begin
      #guard against bringing in an unsupported format
      native_format = Cmr.get_raw_collection_format(concept_id)
      if !(Collection::SUPPORTED_FORMATS.include? native_format) 
        redirect_to home_path
        flash[:alert] = "The system could not ingest the selected record, #{native_format} format records are not currently supported"
        return
      end

      #creating all the collection related objects
      collection_object, new_collection_record, record_data_list, ingest_record = assemble_old_record(concept_id, revision_id, collection_results)

      #saving all the related collection and granule data in a combined transaction
      ActiveRecord::Base.transaction do
        new_collection_record.save!
        record_data_list.each do |record_data|
          record_data.save!
        end
        ingest_record.save!
      end
    end
  end

  def assemble_old_record(concept_id, revision_id, collection_data)
    native_format = Cmr.get_raw_collection_format(concept_id)

    if native_format == "dif10"
      short_name = collection_data["Entry_ID/Short_Name"]
    elsif native_format == "echo10"
      short_name = collection_data["ShortName"]
    else 
      #Guard against records that come in with unsupported types
      return
    end

    ingest_time = DateTime.now
    #finding parent collection
    collection_object = Collection.find_or_create_by(concept_id: concept_id)
    collection_object.short_name = short_name
    collection_object.save!
    #creating collection record related objects
    new_collection_record = Record.new(recordable: collection_object, revision_id: revision_id, format: native_format, closed: false)

    record_data_list = []

    collection_data.each_with_index do |(key, value), i|
      record_data = RecordData.new(record: new_collection_record)
      record_data.last_updated = DateTime.now
      record_data.column_name = key
      record_data.value = value
      record_data.order_count = i
      record_data.daac = concept_id.partition('-').last
      record_data_list.push(record_data)
    end

    ingest_record = Ingest.new(record: new_collection_record, user: (User.find_by id: 1), date_ingested: ingest_time)

    return collection_object, new_collection_record, record_data_list, ingest_record
  end  

  



  ingest_old_revision(args.concept_id, args.revision_id, args.collectionFormat)
end