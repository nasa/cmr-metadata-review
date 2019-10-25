class CollectionsController < ApplicationController

  before_action :authenticate_user!
  before_action :ensure_curation
  before_action :admin_only, only: [:hide, :refresh]
  before_action :find_record, only: [:show, :hide, :refresh]
  before_action :collection_only, only: :refresh

  def show
    if @record
      collection = get_collection_from_record(@record)

      @concept_id = collection.concept_id
      @collection_records = collection.get_records
      @granule_objects = Granule.where(collection: collection)

      # iterates through the granule objects, setting:
      #   1) the latest revision number found in cmr
      #   2) whether the granule has been deleted in cmr
      # This information is used in the view to provide some indicator to the user
      # if the granule has a new revision or the granule has been deleted.
      @granule_objects.each do |granule|
        if Cmr.raw_granule?(granule.concept_id)
          raw_granule_results = Cmr.get_raw_granule_results(granule.concept_id)
          granule.latest_revision_in_cmr = raw_granule_results['revision_id']
          granule.deleted_in_cmr = false
          granule.save!
        else
          granule.deleted_in_cmr = true
          granule.save!
        end
      end

      # determine the values possible for linking collections to granules
      @associated_granules_options = []
      @granule_objects.each do |granule|
        granule.records.each do |record|
          option_val = "#{granule.concept_id}/#{record.revision_id}"
          @associated_granules_options << [option_val, record.id]
        end
      end
      @associated_granules_options << ['No Granule Review', 'No Granule Review']
      @associated_granules_options << ['Undefined', 'Undefined']
    else
      flash[:alert] = 'No record_id provided to find record details'
      redirect_to home_path
    end
  end

  def search
    if can?(:search, :cmr)
      begin
        @search_iterator, @collection_count = Cmr.collection_search(params["free_text"], params["provider"], params["curr_page"])
      rescue Cmr::CmrError => e
        Rails.logger.error("Error retrieving from CMR, #{e.message}")
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
    else
      redirect_to home_path, alert: "You do not have permission to perform this action"
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
    rescue Cmr::CmrError => e
      Rails.logger.error("Error retrieving from CMR, #{e.message}")
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
      rescue Cmr::CmrError => e
        Rails.logger.error("Error retrieving from CMR, #{e.message}")
        flash[:alert] = 'There was an error connecting to the CMR System, please try again'
      rescue Net::OpenTimeout
        flash[:alert] = 'There was an open timeout error connecting to the CMR System, please try again'
      rescue Net::ReadTimeout
        flash[:alert] = 'There was a read timeout error connecting to the CMR System, please try again'
      rescue Timeout::Error
        flash[:alert] = 'The pyCMR script timed out and the collection was unable to be ingested'
      rescue Errors::PythonError => ex
        Rails.logger.error("PyCMR Error: Unknown error ingesting Revision #{params[:revision_id]} with Concept ID #{params[:concept_id]} with error\n#{ex.message}\n#{ex.backtrace}")
        flash[:alert] = 'There was an python error checking metadata'
      rescue => ex
        Rails.logger.error("Error: Unknown error ingesting Revision #{params[:revision_id]} with Concept ID #{params[:concept_id]} with error\n#{ex.backtrace}")
        flash[:alert] = "There was an error ingesting the record into the system #{ex.message}"
      end
    end

    redirect_to home_path
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
    rescue
      flash[:alert] = 'There was an error ingesting the record into the system'
    end

    redirect_to home_path
  end

  private

  def find_record
    # :record_id can be either a single value or a list of IDs. We can only support a single value.
    # Wrapping the paramter in Array ensures that we are working with an Array before getting
    # the first value (Array([]) == []).
    @record = Record.find(Array(params[:record_id]).first)
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
