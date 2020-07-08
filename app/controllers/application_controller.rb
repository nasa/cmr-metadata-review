# Application Controller
class ApplicationController < ActionController::Base
  include ApplicationHelper

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

  def filtered_records
    @records = if current_user.daac_curator?
                 Record.daac(current_user.daac)
               elsif filtered_by?(:daac, ANY_DAAC_KEYWORD)
                 Record.daac(params[:daac])
               else
                 Record.all_records(application_mode)
               end

    # only include collection records
    @records = @records.where(recordable_type: 'Collection').distinct

    @records = @records.where("'#{params[:campaign]}' = ANY (campaign)") if filtered_by?(:campaign, ANY_CAMPAIGN_KEYWORD)

    # Count Second Opinions here for every record
    @second_opinion_counts = RecordData.where(record: @records, opinion: true).group(:record_id).count
  end

  def filtered_by?(param, any_keyword)
    params[param] && params[param] != any_keyword
  end

  def new_session_path(scope)
    new_user_session_path
  end
end