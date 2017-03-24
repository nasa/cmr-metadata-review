class ReportsController < ApplicationController
  before_filter :authenticate_user!
  
  def home
    @collection_ingest_count = Collection.all.length
    @cmr_total_collection_count = Cmr.total_collection_count

    @records = Record.where(recordable_type: "Collection")
  end

end