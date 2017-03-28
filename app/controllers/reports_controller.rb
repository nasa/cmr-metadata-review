class ReportsController < ApplicationController
  before_filter :authenticate_user!
  
  def home
    @collection_ingest_count = Collection.all.length
    @cmr_total_collection_count = Cmr.total_collection_count

    @records = Record.where(recordable_type: "Collection")
  end

  def provider
    if params["daac"].nil?
      redirect_to reports_home_path
    end
    @daac = params["daac"]
    @total_collection_count = Cmr.total_collection_count(@daac)
    @total_ingested = Collection.by_daac(@daac).count

    @percent_ingested = (@total_ingested.to_f * 100 / @total_collection_count).round(2)

    @review_counts = Collection.completed_review_counts(@daac)
    @total_completed = Collection.total_completed(@daac)

    @fields_checked = 
  end

end