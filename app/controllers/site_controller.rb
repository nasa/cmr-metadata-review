class SiteController < ApplicationController

   def home
    #ingested records by user
    # @user_collection_ingests = Curation.user_collection_ingests(current_user)
    @user_collection_ingests = []
    #unfinished review records
    @user_open_collection_reviews = []

    #unreviewed by user, record not closed
    @unreviewed_records = (Record.all.select {|record| record.is_collection? && !record.closed}).select {|record| !record.reviews.where(user: current_user).any?}
    #reviewed by user, record not closed
    @in_process_records = (Record.all.select {|record| record.is_collection? && !record.closed}).select {|record| record.reviews.where(user: current_user).any?}

    #record closed
    @closed_records = Record.all.select {|record| record.is_collection? && record.closed}

    @search_results = []
    @provider_select_list = provider_select_list
  end

end