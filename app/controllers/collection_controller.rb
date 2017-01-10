class CollectionController < ApplicationController

  def record_details
    @concept_id = params["concept_id"]
    if !@concept_id
      flash[:error] = "No concept_id provided to find record details"
      redirect_to curation_home_path
    end

    @collection_records = CollectionRecord.where(concept_id: @concept_id).order(:version_id).reverse_order
  end

end