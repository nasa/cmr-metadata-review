class LoginController < Devise::OmniauthCallbacksController

  def urs
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: "Earth Data Login") if is_navigational_format?
    else
      redirect_to root_path
      flash.notice = "Could not authenticate from Earth Data Login"
    end
  end
end
