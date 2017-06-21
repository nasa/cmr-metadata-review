class SiteController < ApplicationController

   before_filter :authenticate_user!, :except => [:elb_status]
   before_filter :ensure_curation, :except => [:general_home, :elb_status]

   def home
    #ingested records by user
    # @user_collection_ingests = Curation.user_collection_ingests(current_user)
    @user_collection_ingests = []
    #unfinished review records
    @user_open_collection_reviews = []
    #unreviewed by user, record not closed
    @unreviewed_records = (Record.all.select {|record| record.is_collection? && !record.closed && !record.hidden}).select {|record| !record.reviews.where(user: current_user).any?}
    #reviewed by user, record not closed
    @in_process_records = (Record.all.select {|record| record.is_collection? && !record.closed && !record.hidden}).select {|record| record.reviews.where(user: current_user).any?}

    #record closed
    @closed_records = Record.all.select {|record| record.is_collection? && !record.hidden && record.closed && record.cmr_update? }

    @search_results = []
    @provider_select_list = provider_select_list
  end

  def general_home

  end

  def elb_status
    render :json => {"elb_status" => "ok" }
  end

end