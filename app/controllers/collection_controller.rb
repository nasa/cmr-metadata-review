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
    @user_comment = @record_comments.select { |comment| comment.user_id == current_user.id }
    @script_comment = @record_comments.select { |comment| comment.user_id == -1 }.first

    if @script_comment
      @script_comment = JSON.parse(@script_comment.rawJSON)
    end

    if @user_comment.empty?
      @collection_record.add_comment(current_user)
      #grabbing the newly made comment
      @user_comment = CollectionComment.where(user_id: current_user.id, collection_record_id: @collection_record.id).first
    else
      @user_comment = @user_comment.first
    end

    @user_comment_contents = JSON.parse(@user_comment.rawJSON)

    @display_list = []
    JSON.parse(@collection_record.rawJSON)["Collection"].each do |key, value|
      if value.is_a?(String) 
        @display_list.push([key, value, @script_comment[key], @user_comment_contents[key]])
      end
    end

  end

  def comment_update
    @collection_record = CollectionRecord.where(concept_id: params["concept_id"], version_id: params["revision_id"]).first

    @user_comment = CollectionComment.where(user_id: current_user.id, collection_record_id: @collection_record.id).first

    new_comment = JSON.parse(@user_comment.rawJSON)
    params.each do |key, value|
      if key =~ /user_(.*)/
        new_comment[$1] = value
      end
    end

    @user_comment.rawJSON = new_comment.to_json
    @user_comment.save!

    redirect_to collection_record_review_path(concept_id: params["concept_id"], revision_id: params["revision_id"])
  end

end