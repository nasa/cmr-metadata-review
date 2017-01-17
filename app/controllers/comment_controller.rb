class CommentController < ApplicationController

  def update
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