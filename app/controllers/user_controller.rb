class UserController < ApplicationController
  def email_preferences
    redirect_to root_path unless can?(:update_email_preferences, current_user)
    @current_preference = current_user.email_preference
  end

  def update_email_preferences
    if can?(:update_email_preferences, current_user) && current_user.save_email_preference(params[:email_preference])
      redirect_to(email_preferences_path, notice: 'E-mail frequency preference updated.')
    else
      Rails.logger.error "User: #{current_user.uid}:#{current_user.role} attempted to update email preferences and failed."
      redirect_to(email_preferences_path, alert: 'E-mail frequency preference could not be updated.')
    end
  end
end
