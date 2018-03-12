class SiteController < ApplicationController
  include SiteHelper

  before_filter :authenticate_user!, :except => [:elb_status]
  before_filter :ensure_curation, :except => [:general_home, :elb_status]

  def home
    @records = filtered_by_daac? ? Record.daac(params[:daac]) : Record.all
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

  private

  def filtered_by_daac?
    params[:daac] && params[:daac] != ANY_KEYWORD
  end
end
