class GkrKeywordComparisonController < ApplicationController
  def show
    @abstract = params[:abstract]
    @cmr_keywords = params[:cmr_keywords]
  end

  def create
    concept_id = params[:concept_id]
    threshold = params[:threshold]
    collection = Cmr.get_raw_collection(concept_id, 'umm_json')
    abstract_p = collection['Abstract']
    cmr_keywords_p = collection['ScienceKeywords']

    redirect_to gkr_keyword_comparison_path(abstract: abstract_p, cmr_keywords: cmr_keywords_p)
  end
end