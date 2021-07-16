class GkrKeywordComparisonController < ApplicationController
  def show
  end

  def create
    concept_id = params[:concept_id]
    threshold = params[:threshold]
    collection_hash = Cmr.get_collection(concept_id, 'umm_json') # using this method bc get_concept() did not work for all concept ids
  end
end