class LoginController < Devise::OmniauthCallbacksController

  def urs
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted? && !@user.role.nil?
      sign_in_and_redirect @user, event: :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: "Earth Data Login") if is_navigational_format?
    else
      redirect_to root_path
      if (@user.role.nil?)
        flash.notice = "User is not provisioned with the proper ACLs.   Please contact the Operations team."
      else
        flash.notice = "Could not authenticate from Earth Data Login"
      end
    end
  end
end
