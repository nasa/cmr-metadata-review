class GkrKeywordComparisonController < ApplicationController
  def show
    @abstract = params[:abstract]
  end

  def create
    concept_id = params[:concept_id]
    threshold = params[:threshold]
    collection = Cmr.get_raw_collection(concept_id, 'umm_json') # using this method bc get_concept() did not work for all concept ids
    abstract_p = collection['Abstract']

    byebug
 
    redirect_to gkr_keyword_comparison_path(abstract: abstract_p)
  end
end