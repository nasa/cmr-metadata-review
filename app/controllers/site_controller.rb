class SiteController < ApplicationController

  def home

  end

  def curators
    authorize! :access, :curate
  end

  def normal_users
    if !user_signed_in?
      redirect_to :root
      return
    end
  end

end