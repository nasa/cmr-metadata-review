class CollectionsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :ensure_curation
  before_filter :admin_only, only: [:stop_updates, :hide, :refresh]
  before_filter :find_record, only: [:stop_updates, :hide, :refresh]
  before_filter :collection_only, only: [:stop_updates, :refresh]

  def show
    if params[:record_id]
      record = Record.find(params[:record_id])
      collection = get_collection_from_record(record)

      @concept_id = collection.concept_id
      @collection_records = collection.get_records.order(:revision_id).reverse_order
      @granule_objects = Granule.where(collection: collection)
    else
      flash[:alert] = "No record_id provided to find record details"
      redirect_to home_path
    end
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
    @record.hide!
    flash[:notice] = "Revision #{@record.revision_id} of Concept ID #{@record.concept_id} Deleted"

    redirect_to :back
  end

  def refresh
    begin
      if @record.recordable.refresh!(current_user)
        flash[:notice] = "Latest revision for Collection #{@record.concept_id} has been ingested"
      else
        flash[:alert] = "Latest revision for Collection #{@record.concept_id} has already been ingested"
      end
    rescue Cmr::CmrError
      flash[:alert] = 'There was an error connecting to the CMR System, please try again'
    rescue Net::OpenTimeout
      flash[:alert] = 'There was an open timeout error connecting to the CMR System, please try again'
    rescue Net::ReadTimeout
      flash[:alert] = 'There was a read timeout error connecting to the CMR System, please try again'
    rescue Timeout::Error
      flash[:alert] = 'The pyCMR script timed out and the collection was unable to be ingested'
    rescue => ex
      flash[:alert] = 'There was an error ingesting the record into the system'
    end

    redirect_to home_path
  end

  def stop_updates
    collection = @record.recordable
    collection.update_attributes(cmr_update: false)

    flash[:notice] = "Concept_id #{@record.concept_id} has Been Removed from Future CMR Updates"

    redirect_to finished_records_path
  end

  private

  def find_record
    @record = Record.find(params[:record_id])
  end

  def collection_only
    if @record.granule?
      flash[:alert] = "This action cannot be performed on Granules"
      redirect_to finished_records_path
    end
  end

  def get_collection_from_record(record)
    if record.collection?
      record.recordable
    else
      record.recordable.collection
    end
  end
end
