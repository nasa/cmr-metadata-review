class GranulesController < ApplicationController

  before_filter :authenticate_user!
  before_filter :ensure_curation

  def show
  end

  def refresh
    granule    = Granule.find(params[:id])
    collection = granule.collection

    if can?(:refresh_granule, granule)
      granule.delete_self
      collection.add_granule(current_user)
      
      flash[:notice] = "Granule has been refreshed"
    else
      flash[:alert] = "You do not have permission to perform this action"
    end

    redirect_to collection_path(id: 1, concept_id: collection.concept_id)
  end
end
