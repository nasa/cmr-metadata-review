class CollectionController < ApplicationController

  def record_details
    @concept_id = params["concept_id"]
    if !@concept_id
      flash[:error] = "No concept_id provided to find record details"
      redirect_to curation_home_path
    end

    @collection_records = CollectionRecord.where(concept_id: @concept_id).order(:version_id).reverse_order
  end

  def record_review
    @concept_id = params["concept_id"]
    @revision_id = params["revision_id"]

    if !(@concept_id || @revision_id)
      flash[:error] = "Missing the concept_id or revision_id to Locate review"
      redirect_to curation_home_path
    end

    @collection_record = CollectionRecord.where(concept_id: @concept_id, version_id: @revision_id).first
    @record_comments = @collection_record.collection_comments
    @user_record = @record_comments.select { |comment| comment.user_id == current_user.id }

    if @user_record.empty?
      @user_record = @collection_record.add_comment(current_user)
    else
      @user_record = @user_record.first
    end

  end

end