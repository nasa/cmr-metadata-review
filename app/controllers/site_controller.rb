class SiteController < ApplicationController
  include SiteHelper

  before_action :authenticate_user!, :except => [:elb_status]
  before_action :ensure_curation, :except => [:general_home, :elb_status]
  before_action :filtered_records, only: :home

  def home
    records = Record.where(daac: nil)
    return if records.count == 0
    Rails.logger.info("Found #{records.count} record(s) which do not have a DAAC. All records should have a DAAC, please investigate the source of this.") if records.count != 0
    records.each do |record|
      Rails.logger.info("Record without DAAC: #{record.inspect}")
    end
  end

  def general_home
    if current_user
      sign_out current_user
    end
    redirect_to home_path
  end

  def elb_status
    render :json => {"elb_status" => "ok" }
  end
end
