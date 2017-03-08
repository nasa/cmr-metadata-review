class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]

  #all actions require user to be logged in
  #all actions except edit/update (passwords) require user to be admin
  #removed no_auth so that admin can create accounts, users can reset passwords while logged in
  before_filter :ensure_create_access, except: [:edit, :update]
  before_filter :ensure_signed_in
  before_filter :require_no_authentication, except: [:new, :create, :edit, :update]

  #ensuring that only admins can access any registration actions
  def ensure_create_access
    authorize! :access, :create_user
  end

  def ensure_signed_in
    if !user_signed_in?
      redirect_to :root
      return
    end
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

    resource.save
    yield resource if block_given?
    if resource.persisted?
      flash[:notice] = 'new user created'
      redirect_to new_user_registration_path
      return
    else
      flash[:alert] = 'An error occured while creating new user.'
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
  #Added this to be able to configure user roles from admin screen
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
