class CurationController < ApplicationController
  before_filter :ensure_curate_access            

  #ensuring that only curators can access the information
  def ensure_curate_access
    authorize! :access, :curate
  end

  def home
    #ingested records by user
    @user_collection_ingests = Curation.user_collection_ingests
    #unfinished review records
    @user_open_collection_reviews = Curation.user_open_collection_reviews(current_user)
    #all records that do not have a completed review by the user
    @user_available_collection_reviews = Curation.user_available_collection_review(current_user)

    @search_results = Curation.homepage_collection_search_results(params["provider"], params["free_text"])
    @provider_select_list = Curation.provider_select_list
  end

  def search
    @search_iterator = Curation.collection_search(params["free_text"], params["provider"], params["curr_page"])
    @provider_select_list = Curation.provider_select_list
  end

  def ingest_details
    @collection_data = Curation.collection_data(params["concept_id"])
    @already_ingested = CollectionRecord.ingested?(@collection_data["concept_id"], @collection_data["revision_id"])
    @granule_results = Curation.granule_list_from_collection(params["concept_id"])
  end

  def ingest
    ingest_success = CollectionRecord.ingest(params["concept_id"])

    if ingest_success
      flash[:notice] = "The selected collection has been successfully ingested into the system"
    else 
      flash[:alert] = 'The selected record has already been ingested for review'
    end
    redirect_to curation_home_path
  end

end