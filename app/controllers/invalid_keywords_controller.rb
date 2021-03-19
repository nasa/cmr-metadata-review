class InvalidKeywordsController < ApplicationController
  respond_to :csv, :html
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

  def sync
    sync_param = params['clear_sync_date']
    clear_sync_date = false
    if ('true' == sync_param)
      clear_sync_date = true
    end
    @records_processed = KeywordValidator.validate_keywords(clear_sync_date: clear_sync_date)
    respond_to do |format|
      format.html do
        format.html { render html: 'sync'}
      end
    end
  end
end
