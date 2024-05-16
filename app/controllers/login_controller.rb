class LoginController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token unless !Rails.env.development?
  def urs

    begin
      @user = User.from_omniauth(request.env["omniauth.auth"])

      instance = UserSingleton.instance
      instance.current_user = @user
      Rails.logger.info("Google Analytics - Users #{@user.uid} from provider/role #{@user.role}")
    rescue Cmr::CmrError => e
      flash.notice = e.message
      redirect_to root_path and return
    end

    # before we sign user in, make sure two things:
    # 1) the user is in database, they should be as the result of calling User.from_omniauth
    # 2) A role has been assigned to the user.   In order to be given a role, they must have an ACL in CMR.  If they
    # don't the role will be nil.
    if @user.persisted? && !@user.role.nil?
      sign_in_and_redirect @user, event: :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: "Earthdata Login") if is_navigational_format?
    else
      redirect_to root_path
      if (@user.role.nil?)
        flash.notice = "The user is not provisioned with the proper ACLs. Please contact User Support at support@earthdata.nasa.gov."
      else
        flash.notice = "Could not authenticate from Earthdata Login"
      end
    end
  end

  def developer
    begin
      auth = request.env["omniauth.auth"]
      auth.info.name = "John Smith" if auth.info.name.blank?
      auth.info.email_address = params["email"]
      auth.info.email_address = "john.smith@somewhere.com" if auth.info.email_address.blank?
      @user = User.from_omniauth(auth)

      instance = UserSingleton.instance
      instance.current_user = @user
    rescue Cmr::CmrError => e
      flash.notice = e.message
      redirect_to root_path and return
    end

    sign_in_and_redirect @user, event: :authentication #this will throw if @user is not activated
    set_flash_message(:notice, :success, kind: "Developer Login") if is_navigational_format?
  end
end
