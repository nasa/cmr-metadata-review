class GranulesController < ApplicationController

  before_filter :authenticate_user!
  before_filter :ensure_curation

  def show
  end

  def refresh
    granule    = Granule.find(params[:id])
    record     = granule.records.find(params[:record_id])
    collection = granule.collection

    authorize! :refresh_granule, granule

    if record.open?
      granule.delete_self
      collection.add_granule(current_user)
      
      flash[:notice] = "A new granule has been selected for this collection"
    else
      flash[:alert] = "This granule is in review, and can no longer be changed to a different granule"
    end

    redirect_to collection_path(id: 1, concept_id: collection.concept_id)
  end
end
