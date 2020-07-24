class DiscussionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_curation

  def update
    discussion = Discussion.find_by(id: params[:id])
    discussion.update(comment: params[:discussion])
    redirect_to review_path(id: params[:record_id], section_index: params[:section_index])
  end

  def destroy
    discussion = Discussion.find_by(id: params[:id])
    discussion.destroy
    redirect_to review_path(id: params[:record_id], section_index: params[:section_index])
  end
end
