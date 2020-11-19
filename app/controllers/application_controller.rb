class ApplicationController < ActionController::Base
  include ApplicationHelper
  before_action :assign_user
  after_action :cleanup_user

  private
  def render_404(exception = nil)
    if exception
      logger.info "Rendering 404: #{exception.message}"
    end

    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

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
    throw(:abort) unless authorize! :access, :curate
  end

  def admin_only
    unless current_user.admin?
      flash[:alert] = "You do not have permission to perform this action"
      redirect_to home_path
    end
  end

  def filtered_by?(param, any_keyword)
    params[param] && params[param] != any_keyword
  end

  def new_session_path(scope)
    new_user_session_path
  end

  def assign_user
    UserSingleton.instance.current_user = current_user
  end

  def cleanup_user
    UserSingleton.clear
  end
end