class SiteController < ApplicationController
  include SiteHelper

  before_action :authenticate_user!, :except => [:elb_status]
  before_action :ensure_curation, :except => [:general_home, :elb_status]
  before_action :filtered_records, only: :home

  def home
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
