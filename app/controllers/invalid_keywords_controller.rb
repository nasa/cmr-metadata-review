class InvalidKeywordsController < ApplicationController
  respond_to :csv
  def csv_report
    @records = InvalidKeyword.get_invalid_keywords(params["provider"])
    respond_to do |format|
      format.html
      format.csv { send_data @records.to_csv, filename: "invalid_keywords-#{Date.today}.csv" }
    end
  end
end
