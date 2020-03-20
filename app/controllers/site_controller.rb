class SiteController < ApplicationController
  include SiteHelper

  before_action :authenticate_user!, :except => [:elb_status]
  before_action :ensure_curation, :except => [:general_home, :elb_status]
  before_action :filtered_records, only: :home

  def home
    num_records = Record.where(daac: nil).count
    Rails.logger.info("Found #{num_records} record(s) which do not have a DAAC.  All records should have a DAAC, please investigate the source of this.") if num_records != 0
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
