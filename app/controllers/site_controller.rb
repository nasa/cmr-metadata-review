class SiteController < ApplicationController

   def home
    #ingested records by user
    # @user_collection_ingests = Curation.user_collection_ingests(current_user)
    @user_collection_ingests = []
    #unfinished review records
    @user_open_collection_reviews = []

    # @user_open_collection_reviews = Curation.user_open_collection_reviews(current_user)
    #all records that do not have a completed review by the user
    # @user_available_collection_reviews = Curation.user_available_collection_review(current_user)
    @user_available_collection_reviews = current_user.records_not_reviewed
    # @search_results = Curation.homepage_collection_search_results(params["provider"], params["free_text"], current_user)
    @search_results = []
    @provider_select_list = provider_select_list
  end

end