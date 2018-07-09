class GranulesController < ApplicationController

  before_filter :authenticate_user!
  before_filter :ensure_curation

  def show
  end

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
