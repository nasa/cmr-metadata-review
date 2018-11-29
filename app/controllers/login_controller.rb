class LoginController < Devise::OmniauthCallbacksController

  def urs

    begin
      @user = User.from_omniauth(request.env["omniauth.auth"])
    rescue Cmr::CmrError => e
      redirect_to root_path
      flash.notice = e.message
      return
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
        flash.notice = "User is not provisioned with the proper ACLs.   Please contact the Earthdata Operations team."
      else
        flash.notice = "Could not authenticate from Earthdata Login"
      end
    end
  end
end
