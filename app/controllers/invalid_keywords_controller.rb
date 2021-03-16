class InvalidKeywordsController < ApplicationController
  respond_to :csv
  def csv_report
    provider = params["provider"]
    # A provider might be a "virtual daac" and really encompass multiple providers.
    providers = ApplicationHelper::providers(provider) unless provider.nil?
    @records = InvalidKeyword.get_invalid_keywords(providers)
    respond_to do |format|
      format.html
      format.csv { send_data @records.to_csv, filename: "invalid_keywords-#{Date.today}.csv" }
    end
  end
end
