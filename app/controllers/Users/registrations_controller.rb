class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]

  #these go together.  Removing Authentication on new and create because Admin auth is added
  before_filter :ensure_access
  before_filter :require_no_authentication, except: [:new, :create]

  #ensuring that only admins can access any registration actions
  def ensure_access
    authorize! :access, :sign_up
  end

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  #This is a copy of the base Registrations Controller method
  #Except, it removes all the after user creation functionality
  #because this site has admins create accounts, so the admin should remain logged in after new account creation.
  def create
    build_resource(sign_up_params)

    byebug
    resource.save
    yield resource if block_given?
    if resource.persisted?
      flash[:notice] = 'new user created'
      redirect_to new_user_registration_path
      return
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up) << :curator
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
