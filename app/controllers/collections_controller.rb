class CollectionsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :ensure_curation


  def show
    if !(params["concept_id"])
      flash[:alert] = "No concept_id provided to find record details"
      redirect_to home_path
      return
    end

    collection = Collection.find_by(concept_id: params["concept_id"])
    #allowing action to also accept granule concept id's
    if collection.nil?
      granule = Granule.find_by(concept_id: params["concept_id"])
      unless granule.nil?
        collection = granule.collection
      end
    end

    if collection.nil?
      flash[:alert] = "No Collection Could be Found With Concept Id"
      redirect_to home_path
      return
    end

    @concept_id = collection.concept_id
    @collection_records = collection.get_records.order(:revision_id).reverse_order

    @granule_objects = Granule.where(collection: collection)
  end

  def search
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
      flash[:alert] = 'There was an open timeout error while connecting to the CMR System, please try again'
      redirect_to home_path
      return
    rescue Net::ReadTimeout
      flash[:alert] = 'There was a read timeout error connecting to the CMR System, please try again'
      redirect_to home_path
      return
    rescue Exception => ex
      flash[:alert] = 'There was an error ingesting the record into the system'
      redirect_to home_path
      return
    end
  end

  def create
    # Guard against creating a duplicate record
    if Collection.record_exists?(params[:concept_id], params[:revision_id])
      flash[:alert] = 'This collection has already been ingested into the system'
    else
      begin
        Collection.create_new_record(params[:concept_id], params[:revision_id], current_user, true)

        flash[:notice] = "The selected collection has been successfully ingested into the system"
      rescue Cmr::CmrError
        flash[:alert] = 'There was an error connecting to the CMR System, please try again'
      rescue Net::OpenTimeout
        flash[:alert] = 'There was an open timeout error connecting to the CMR System, please try again'
      rescue Net::ReadTimeout
        flash[:alert] = 'There was a read timeout error connecting to the CMR System, please try again'
      rescue Timeout::Error
        flash[:alert] = 'The pyCMR script timed out and the collection was unable to be ingested'
      rescue => ex
        Rails.logger.error("PyCMR Error: Unknown error ingesting Revision #{params[:revision_id]} with Concept ID #{params[:concept_id]} with error\n#{ex.backtrace}")
        flash[:alert] = 'There was an error ingesting the record into the system'
      end
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
      Rails.logger.error("Delete Error: Revision #{params["revision_id"]}, Concept_id #{params["concept_id"]} not Deleted")
      redirect_to home_path
      return
    end

    record.hide
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
