class InvalidKeywordsController < ApplicationController
  respond_to :csv
  def csv_report
    render csv: InvalidKeyword.all
  end
end
