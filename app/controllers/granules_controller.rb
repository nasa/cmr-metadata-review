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

    granule.destroy
    collection.add_granule(current_user)
    flash[:notice] = "A new granule has been selected for this collection"

    redirect_to collection_path(id: 1, record_id: collection.records.first.id)
  end
end
