class InvalidKeywordsController < ApplicationController
  respond_to :csv
  def csv_report
    render csv: User.all
  end
end
