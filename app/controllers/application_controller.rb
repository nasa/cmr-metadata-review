class ApplicationController < ActionController::Base
  include ApplicationHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # http_basic_authenticate_with name: "cmruser", password: "dashpass"


  #saving error from CanCan for users going beyond allowed pages
  rescue_from CanCan::AccessDenied do |exception|
    if current_user
      redirect_to general_home_path, :alert => exception.message
    else
      redirect_to root_url, :alert => exception.message
    end
  end

  def after_sign_in_path_for(resource)
    if can? :access, :curate
      home_path
    else
      general_home_path
    end
  end

  def ensure_curation
    authorize! :access, :curate
  end

  def admin_only
    unless current_user.admin
      flash[:alert] = "You do not have permission to perform this action"
      redirect_to home_path
    end
  end

  def filtered_records
    @records = if current_user.role == "daac_curator"
      Record.daac(current_user.daac)
    else
      filtered_by_daac? ? Record.daac(params[:daac]) : Record.all
    end
  end

  private

  def filtered_by_daac?
    params[:daac] && params[:daac] != ANY_KEYWORD
  end
end
