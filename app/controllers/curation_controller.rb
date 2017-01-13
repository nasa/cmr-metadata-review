class CurationController < ApplicationController
  before_filter :ensure_curate_access            

  #ensuring that only curators can access the information
  def ensure_curate_access
    authorize! :access, :curate
  end

  def home
    #ingested records by user
    @user_collection_ingests = Curation.user_collection_ingests(current_user)
    #unfinished review records
    @user_open_collection_reviews = Curation.user_open_collection_reviews(current_user)
    #all records that do not have a completed review by the user
    @user_available_collection_reviews = Curation.user_available_collection_review(current_user)

    @search_results = Curation.homepage_collection_search_results(params["provider"], params["free_text"], current_user)
    @provider_select_list = Curation.provider_select_list
  end

  def search
    @search_iterator, @collection_count = Curation.collection_search(params["free_text"], params["provider"], params["curr_page"])
    @free_text = params["free_text"]
    @provider = params["provider"]
    @curr_page = params["curr_page"]
    @provider_select_list = Curation.provider_select_list
  end

  def ingest_details
    @collection_data = Curation.collection_data(params["concept_id"])
    @already_ingested = CollectionRecord.ingested?(@collection_data["concept_id"], @collection_data["revision_id"])
    @granule_results = Curation.granule_list_from_collection(params["concept_id"])
  end

  def ingest
    ingest_success = CollectionRecord.ingest_with_granules(params["concept_id"], params["revision_id"], params["granulesCount"], current_user)

    if ingest_success
      byebug
      collection = CollectionRecord.where(concept_id: params["concept_id"], version_id: params["revision_id"]).first
      collection_script_success = collection.evaluate_script

      granules_list = GranuleRecord.where(collection_concept_id: params["concept_id"])
      granule_script_success = true
      #filter for those with no automated check
      granules_list = granules_list.select { |granule| !(granule.granule_reviews.where(user_id: -1).any?) }
      granules_list.each { |granule| 
        script_result = granule.evaluate_script; 
        granule_script_success = script_result if !script_result }

      script_results_phrase = ", the automated reviews were not completed for all collections and granules"
      if collection_script_success && granule_script_success
        script_results_phrase = ", and all automated scripts ran successfully"
      end
    end

    if ingest_success
      flash[:notice] = "The selected collection has been successfully ingested into the system" + script_results_phrase.to_s
    else 
      flash[:alert] = 'There was an error ingesting the record into the system' + script_results_phrase.to_s
    end
    redirect_to curation_home_path
  end

end