class ReviewController < ApplicationController

  def show
    @concept_id = params["concept_id"]
    @revision_id = params["revision_id"]

    if !(@concept_id || @revision_id)
      flash[:error] = "Missing the concept_id or revision_id to Locate review"
      redirect_to curation_home_path
    end

    @collection_record = Collection.find_record(@concept_id, @revision_id)
    @record_comments = @collection_record.comments
    @user_comment = @record_comments.select { |comment| comment.user_id == current_user.id }
    @other_users_comments = @record_comments.select { |comment| (comment.user_id != current_user.id && comment.user_id != -1) }

    @script_comment = @record_comments.select { |comment| comment.user_id == -1 }.first

    if @script_comment
      @script_comment = JSON.parse(@script_comment.rawJSON)
    end

    if @user_comment.empty?
      @collection_record.add_comment(current_user.id)
      #grabbing the newly made comment
      @user_comment = Comment.where(user: current_user, record: @collection_record).first
    else
      @user_comment = @user_comment.first
    end

    @user_comment_contents = JSON.parse(@user_comment.rawJSON)

    @display_list = []

    JSON.parse(@collection_record.rawJSON)["Collection"].each do |key, value|
      if value.is_a?(String) 
        @display_list.push({key: key, value: value, script: @script_comment[key], reviewer: @user_comment_contents["Collection"][key]})
      end
    end

  end


end