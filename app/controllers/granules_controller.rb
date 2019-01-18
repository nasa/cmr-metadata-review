class GranulesController < ApplicationController

  before_filter :authenticate_user!
  before_filter :ensure_curation

  def show
  end

  # Pulls a new random granule and associates with the specified collection id.
  def create
    collection = Collection.find(params[:id])
    authorize! :create_granule, collection
    collection.add_granule_with_concept_id(current_user, collection.concept_id)
    flash[:notice] = collection.granules.count > 0 ?  "A new random granule has been added for this collection" : "No Granules Available!"
    redirect_to collection_path(id: 1, record_id: collection.records.first.id)
  end

  # Deletes the specified granule record (and its associated review) using the
  # specified granule id.
  def destroy
    granule = Granule.find(params[:id])
    granule_record = Record.find(params[:record_id])
    collection = granule.collection

    authorize! :delete_granule, granule

    granule_record.destroy
    if granule.records == 0
      granule.destroy
    end
    flash[:notice] = "Granule has been deleted."

    redirect_to collection_path(id: 1, record_id: collection.records.first.id)
  end

  # Pulls in the latest granule revision and associates it with the collection
  def pull_latest
    granule = Granule.find(params[:id])
    collection = granule.collection
    Granule.add_new_revision_to_granule(granule, current_user)

    flash[:notice] = "A new granule revision has been added for this collection."
    redirect_to collection_path(id: 1, record_id: collection.records.first.id)
  end

  # Removes the specified granule and adds a new random granule to the
  # collection.
  def replace
    granule = Granule.find(params[:id])
    record = granule.records.find(params[:record_id])
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

    granule.destroy
    collection.add_granule(current_user)
    flash[:notice] = "A new granule has been selected for this collection"

    redirect_to collection_path(id: 1, record_id: collection.records.first.id)
  end


end