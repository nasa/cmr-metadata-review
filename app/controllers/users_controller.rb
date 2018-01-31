# This is for editing a user outside of what Devise
# gives us. For Devise methods, see controllers under
# the users folder.
class UsersController < ApplicationController
  before_filter :authenticate_user!

  def edit
  end

  def update
    if current_user.update_attributes(user_params)
      flash[:notice] = "User Email has been updated"
      redirect_to home_path
    else
      flash.now[:alert] = user_error_alert
      render "edit"
    end
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end

  def user_error_alert
    "User could not be updated: " +
      current_user.errors.full_messages.join(". ")
  end
end
