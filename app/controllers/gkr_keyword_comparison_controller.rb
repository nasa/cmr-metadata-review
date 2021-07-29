class GkrKeywordComparisonController < ApplicationController
  def show
    @abstract = params[:abstract]
    @cmr_keywords = params[:cmr_keywords]
  end

  def create
    concept_id = params[:concept_id]
    threshold = params[:threshold]
    collection = Cmr.get_raw_collection(concept_id, 'umm_json')
    abstract_for_gkr = collection['Abstract']
    curated_science_keywords = collection['ScienceKeywords']

    redirect_to gkr_keyword_comparison_path(abstract: abstract_for_gkr, cmr_keywords: curated_science_keywords)
  end
end