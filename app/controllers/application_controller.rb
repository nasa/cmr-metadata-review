class ApplicationController < ActionController::Base
  include ApplicationHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # https://guides.rubyonrails.org/security.html#csrf-countermeasures
  # https://medium.com/rubyinside/a-deep-dive-into-csrf-protection-in-rails-19fa0a42c0ef
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
    @records = if current_user.daac_curator?
      Record.daac(current_user.daac)
    else
      filtered_by?(:daac, ANY_DAAC_KEYWORD) ? Record.daac(params[:daac]) : Record.all
    end

    if filtered_by?(:campaign, ANY_CAMPAIGN_KEYWORD)
      @records = @records.campaign(params[:campaign])
    end

    # Count Second Opinions here for every record
    @second_opinion_counts = RecordData.where(record: @records, opinion: true).group(:record_id).count

    @records = @records.includes({ingest: :user}, :reviews)

    # Version ID is only field we need to render on the home page, so just load that
    @records = @records.includes(:record_datas).where(record_data: { column_name: ['VersionId', 'Entry_ID/Version', 'Version']}).references(:record_data)
  end

  private

  def filtered_by?(param, any_keyword)
    params[param] && params[param] != any_keyword
  end

end
