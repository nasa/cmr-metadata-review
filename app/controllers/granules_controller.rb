# Note: These actions (create, destroy, replace, etc.) are acting on granule
# reviews and not modifying CMR in anyway.
class GranulesController < ApplicationController

  before_filter :authenticate_user!
  before_filter :ensure_curation

  def show
  end

  # Pulls a new random granule and associates with the specified "collection id".
  def create
    collection = Collection.find(params[:id])
    authorize! :create_granule, collection
    begin
      granule = collection.add_granule_with_concept_id(current_user, collection.concept_id)
      flash[:notice] = granule.nil? ? "No Granules Available!" : "A new random granule has been added for this collection"
      redirect_to collection_path(id: 1, record_id: collection.records.first.id)
    rescue ActiveRecord::ActiveRecordError => e
      flash[:notice] = 'Sorry, Error occurred creating granule review.'
      Rails.logger.error("Sorry, Error occurred creating granule review.  error=#{e.message}")
      redirect_to collection_path(id: 1, record_id: collection.records.first.id)
    rescue Cmr::CmrError => e
      flash[:notice] = 'Sorry, Error occurred retrieving granule metadata from CMR.'
      Rails.logger.error("Sorry, Error occurred retrieving granule metadata from CMR.  error=#{e.message}")
      redirect_to collection_path(id: 1, record_id: collection.records.first.id)
    end
  end

  # Deletes the specified granule record (i.e., specific revision)using the
  # specified "granule record id."
  def destroy
    granule = Granule.find(params[:id])
    granule_record = Record.find(params[:record_id])
    collection = granule.collection

    authorize! :delete_granule, granule

    begin
      granule_record.destroy
      if granule.records == 0
        granule.destroy
      end
      flash[:notice] = "Granule has been deleted."
      redirect_to collection_path(id: 1, record_id: collection.records.first.id)
    rescue ActiveRecord::ActiveRecordError => e
      flash[:notice] = 'Sorry, Error occurred deleting granule review.'
      Rails.logger.error("Sorry, Error occurred deleting granule review.  error=#{e.message}")
      redirect_to collection_path(id: 1, record_id: collection.records.first.id)
    rescue Cmr::CmrError => e
      flash[:notice] = 'Sorry, Error occurred retrieving granule metadata from CMR.'
      Rails.logger.error("Sorry, Error occurred retrieving granule metadata from CMR.  error=#{e.message}")
      redirect_to collection_path(id: 1, record_id: collection.records.first.id)
    end
  end

  # Pulls in the latest granule revision and associates it with the collection
  # using the specified "granule id."
  def pull_latest
    granule = Granule.find(params[:id])
    collection = granule.collection
    begin
      Granule.add_new_revision_to_granule(granule, current_user)
      flash[:notice] = "A new granule revision has been added for this collection."
      redirect_to collection_path(id: 1, record_id: collection.records.first.id)
    rescue ActiveRecord::ActiveRecordError => e
      flash[:notice] = 'Sorry, Error occurred creating a new granule review.'
      Rails.logger.error("Sorry, Error occurred creating a new granule review.  error=#{e.message}")
      redirect_to collection_path(id: 1, record_id: collection.records.first.id)
    rescue Cmr::CmrError => e
      flash[:notice] = 'Sorry, Error occurred retrieving granule metadata from CMR.'
      Rails.logger.error("Sorry, Error occurred retrieving granule metadata from CMR.  error=#{e.message}")
      redirect_to collection_path(id: 1, record_id: collection.records.first.id)
    end
  end


  # This performs two actions.   First, it removes the specified granule using the "granule id" and then ingests a
  # new random granule from CMR and associates it with the collection.
  def replace
    granule = Granule.find(params[:id])
    collection = granule.collection

    authorize! :replace_granule, granule

    # Removing temporarily until we come up with a process flow that allows them to reopen the record after it has
    # been closed.   A new ticket should be created allowing them to reopen a record.

    # if record.open?
    #   granule.destroy
    #   collection.add_granule(current_user)
    #
    #   flash[:notice] = "A new granule has been selected for this collection"
    # else
    #   flash[:alert] = "This granule is in review, and can no longer be changed to a different granule"
    # end
    #

    begin
      granule.destroy
      collection.add_granule(current_user)
      flash[:notice] = "A new granule has been selected for this collection"
      redirect_to collection_path(id: 1, record_id: collection.records.first.id)
    rescue ActiveRecord::ActiveRecordError => e
      flash[:notice] = 'Sorry, Error occurred replacing the granule review.'
      Rails.logger.error("Sorry, Error occurred replacing the granule review.  error=#{e.message}")
      redirect_to collection_path(id: 1, record_id: collection.records.first.id)
    rescue Cmr::CmrError => e
      flash[:notice] = 'Sorry, Error occurred retrieving granule metadata from CMR.'
      Rails.logger.error("Sorry, Error occurred retrieving granule metadata from CMR.  error=#{e.message}")
      redirect_to collection_path(id: 1, record_id: collection.records.first.id)
    end
  end

  def ingest_specific
      collection = Collection.find(params[:id])
      authorize! :create_granule, collection
      collection_concept_id = collection.concept_id
      granule_concept_id = params["granule_concept_id"]

      record = collection.granules.find_by concept_id: granule_concept_id
      unless record.nil?
        flash[:notice] = "Sorry, granule review #{granule_concept_id} already exists!"
        redirect_to collection_path(id: 1, record_id: collection.records.first.id) and return
      end

      begin
        Granule.ingest_specific(collection_concept_id, granule_concept_id, current_user)
        flash[:notice] = "Granule #{granule_concept_id} ingested."
      rescue Cmr::CmrError => e
        flash[:notice] = e.message
      rescue StandardError => e
        flash[:notice] = "Sorry, granule #{granule_concept_id} could not be ingested."
        Rails.logger.error("Sorry, granule #{granule_concept_id} could not be ingested.  error=#{e.message}")
      end
      redirect_to collection_path(id: 1, record_id: collection.records.first.id)
  end
end