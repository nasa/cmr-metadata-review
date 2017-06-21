class CollectionsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :ensure_curation


  def show
    @concept_id = params["concept_id"]
    if !@concept_id
      flash[:error] = "No concept_id provided to find record details"
      redirect_to home_path
      return
    end

    collection = Collection.find_by(concept_id: @concept_id)

    if collection.nil?
      flash[:error] = "No Collection Could be Found With Concept Id"
      redirect_to home_path
      return
    end

    @collection_records = collection.get_records.order(:revision_id).reverse_order

    @granule_objects = Granule.where(collection: collection)
    # @granule_records = granule_objects.map { |granule|}
  end

  def search
    @free_text = params["free_text"]
    @provider = params["provider"]
    @curr_page = params["curr_page"]
    @provider_select_list = provider_select_list

    begin
      @search_iterator, @collection_count = Cmr.collection_search(params["free_text"], params["provider"], params["curr_page"])
    rescue Cmr::CmrError
      flash[:alert] = 'There was an error connecting to the CMR System, please try again'
      redirect_to home_path
      return
    rescue Net::OpenTimeout
      flash[:alert] = 'There was an error connecting to the CMR System, please try again'
      redirect_to home_path
      return
    rescue Net::ReadTimeout
      flash[:alert] = 'There was an error connecting to the CMR System, please try again'
      redirect_to home_path
      return
    rescue
      flash[:alert] = 'There was an error ingesting the record into the system'
      redirect_to home_path
      return
    end
  end

  def new
    #setting value in case of cmr error
    @granule_count = 0
    @concept_id = params["concept_id"]
    @revision_id = params["revision_id"]
    @already_ingested = Collection.record_exists?(@concept_id, @revision_id)
    if @already_ingested
      @cmr_update = (Collection.find_by concept_id: @concept_id).update?
    end

    begin
      collection_data = Cmr.get_collection(params["concept_id"])
      @short_name = collection_data["ShortName"]  
      @granule_count = Cmr.collection_granule_count(@concept_id)
    rescue Cmr::CmrError
      flash[:alert] = 'There was an error connecting to the CMR System, please try again'
      redirect_to home_path
      return
    rescue Net::OpenTimeout
      flash[:alert] = 'There was an error connecting to the CMR System, please try again'
      redirect_to home_path
      return
    rescue Net::ReadTimeout
      flash[:alert] = 'There was an error connecting to the CMR System, please try again'
      redirect_to home_path
      return
    rescue Exception => ex
      flash[:alert] = 'There was an error ingesting the record into the system'
      redirect_to home_path
      return
    end
  end

  #this is a behemoth method, but it does several things
  #creates and saves collection record, all related granule records and ingests
  #runs evaluation script over collection record and all granules and saves results as comments
  def create
    concept_id = params["concept_id"]
    revision_id = params["revision_id"]

    #guard against creating a duplicate record
    if Collection.record_exists?(concept_id, revision_id)
      redirect_to home_path
      flash[:alert] = 'This collection has already been ingested into the system'
      return
    end

    begin
      #guard against bringing in an unsupported format
      native_format = Cmr.get_raw_collection_format(concept_id)
      if !(Collection::SUPPORTED_FORMATS.include? native_format) 
        redirect_to home_path
        flash[:alert] = "The system could not ingest the selected record, #{native_format} format records are not currently supported"
        return
      end

      #creating all the collection related objects
      collection_object, new_collection_record, record_data_list, ingest_record = Collection.assemble_new_record(concept_id, revision_id, current_user)

      granules_components = []
      #only selecting granules for certain formats per business rules
      if Collection::INCLUDE_GRANULE_FORMATS.include? native_format 
          #nil gets turned into 0
          granules_count = params["granulesCount"].to_i
          #creating all the Granule related objects
          granules_components = Granule.assemble_granule_components(concept_id, granules_count, collection_object, current_user)
      end

      #saving all the related collection and granule data in a combined transaction
      ActiveRecord::Base.transaction do
        new_collection_record.save!
        record_data_list.each do |record_data|
          record_data.save!
        end
        ingest_record.save!
        granules_components.flatten.each { |savable_object| 
                                              if savable_object.is_a?(Array)
                                                savable_object.each do |savable_item|
                                                  savable_item.save!
                                                end
                                              else
                                                savable_object.save! 
                                              end
                                          }
      end

      #In production there is an egress issue with certain link types given in metadata
      #AWS hangs requests that break ingress/egress rules.  Added this timeout to catch those
      Timeout::timeout(12) {
        new_collection_record.create_script
      }

      #getting list of records for script
      granule_records = granules_components.flatten.select { |savable_object| savable_object.is_a?(Record) }
      granule_records.each do |record|
        record.create_script
      end
  
      flash[:notice] = "The selected collection has been successfully ingested into the system"
    rescue Cmr::CmrError
      flash[:alert] = 'There was an error connecting to the CMR System, please try again'
    rescue Net::OpenTimeout
      flash[:alert] = 'There was an error connecting to the CMR System, please try again'
    rescue Net::ReadTimeout
      flash[:alert] = 'There was an error connecting to the CMR System, please try again'
    rescue Timeout::Error
      flash[:alert] = 'The automated script timed out and was unable to finish, collection ingested without automated script'
    rescue
      flash[:alert] = 'There was an error ingesting the record into the system'
    end
      
    redirect_to home_path
  end

  def hide
    if !current_user.admin
      flash[:alert] = "User not authorized to delete records"
      redirect_to home_path
      return
    end

    record = Collection.find_record(params["concept_id"], params["revision_id"])

    if record.nil?
      flash[:alert] = "Error: Record was not Deleted"
      redirect_to home_path
      return
    end

    record.hidden = true
    record.save

    flash[:notice] = "Revision #{params["revision_id"]} of Concept_id #{params["concept_id"]} Deleted"
    redirect_to home_path
  end

  def stop_updates
    collection = Collection.find_by concept_id: params["concept_id"]
    if !collection.nil?
      collection.cmr_update = false;
    end
    collection.save

    flash[:notice] = "Revision #{params["revision_id"]} of Concept_id #{params["concept_id"]} has Been Removed from Future CMR Updates"
    redirect_to home_path
  end
end