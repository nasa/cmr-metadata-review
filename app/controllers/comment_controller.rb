class CommentController < ApplicationController

  def update

    @collection_record = Collection.find_record(params["concept_id"], params["revision_id"])

    @user_comment = @collection_record.comments.where(user: current_user).first

    new_comment = JSON.parse(@user_comment.rawJSON)
    params.each do |key, value|
      if key =~ /user_(.*)/
        new_comment["Collection"][$1] = value
      end
    end

    @user_comment.rawJSON = new_comment.to_json
    @user_comment.save!

    flash[:notice] = "User Comments have been saved"

    redirect_to collection_record_review_path(concept_id: params["concept_id"], revision_id: params["revision_id"])
  end
end