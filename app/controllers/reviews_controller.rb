class ReviewsController < ApplicationController
  include ReviewsHelper

  def show
    record = Record.find_by id: params[:id]
    section_index = params["section_index"]

    @collection_record = Record.find_by id: params[:id]
    @record_comments = @collection_record.comments
    @user_comment = @record_comments.select { |comment| comment.user_id == current_user.id }

    # @other_users_comments = @record_comments.select { |comment| (comment.user_id != current_user.id && comment.user_id != -1) }
    # @other_users_comments_count = @other_users_comments.length

    @script_comment = @record_comments.select { |comment| comment.user_id == -1 }.first
    if @script_comment
      @script_comment = JSON.parse(@script_comment.rawJSON)
    end

    #a boolean test to determine if any review exists (should replace with review??)
    if @user_comment.empty?
      @collection_record.add_review(current_user.id)
      @collection_record.add_flag(current_user.id)
      @collection_record.add_comment(current_user.id)
    end

    @user_comment = Comment.where(user: current_user, record: @collection_record).first
    @user_flag = Flag.where(user: current_user, record: @collection_record).first
    @user_review = Review.where(user: current_user, record: @collection_record).first

    if @user_review.review_state == 1
      @review_complete = "checked"
    else 
      @review_complete = ""
    end

    @user_comment_contents = JSON.parse(@user_comment.rawJSON)
    @user_flag = JSON.parse(@user_flag.rawJSON)

    @display_list = []

    @bubble_data = record.section_bubble_data(0)

    JSON.parse(@collection_record.rawJSON).each do |key, value|
      if value.is_a?(String) 
        display_hash = {}
        display_hash[:key] = key
        display_hash[:value] = value
        display_hash[:script] = @script_comment[key]
        display_hash[:reviewer_comment] = @user_comment_contents[key]
        display_hash[:flag] = @user_flag[key]
        
        # @other_users_comments.each_with_index do | comments, index | 
        #   display_hash[("other_user" + index.to_s).to_sym] = comments[key]
        # end

        @display_list.push(display_hash)
      end
    end

    @section_titles = record.section_titles(section_index)
    @flagged_by_script = record.binary_script_values
    @script_values = record.script_values
    @previous_values = nil
    @current_values = record.values
    @flags = record.flag_values
    @recommendations = record.recommendation_values
    @second_opinions = record.second_opinion_values

    @color_codes = record.color_codes

  end




  def update

    record = Record.find_by id: params[:id]

    recommendations = record.recommendation_values
    params.each do |key, value|
      if key =~ /recommendation_(.*)/
        recommendations[$1] = value
      end
    end
    record.update_recommendation(recommendations)

    color_codes = record.color_codes
    params.each do |key, value|
      if key =~ /color_code_(.*)/
        color_codes[$1] = value
      end
    end
    record.update_color_codes(color_codes)

  #   @collection_record = Collection.find_record(params["concept_id"], params["revision_id"])

  #   #updating comment text
  #   @user_comment = @collection_record.comments.where(user: current_user).first
  #   new_comment = JSON.parse(@user_comment.rawJSON)
  #   params.each do |key, value|
  #     if key =~ /user_(.*)/
  #       new_comment[$1] = value
  #     end
  #   end
  #   @user_comment.rawJSON = new_comment.to_json
  #   @user_comment.save!


  #   #updating flags
  #   @user_flags = @collection_record.flags.where(user: current_user).first
  #   new_flags = JSON.parse(@user_flags.rawJSON)
  #   params.each do |key, value|
  #     if key =~ /userflag_(.*)/
  #       new_flags[$1] = value
  #     end
  #   end
  #   @user_flags.rawJSON = new_flags.to_json
  #   @user_flags.save!


  #   #updating review
  #   if params["userreviewcheck"] == "done"
  #     @user_review = @collection_record.reviews.where(user: current_user).first
  #     if @user_review.review_state == 0
  #       @user_review.review_state = 1
  #       @user_review.review_completion_date = DateTime.now
  #       @user_review.save!
  #     end

  #     flash[:notice] = "User Review has been saved"
  #     redirect_to collection_path(id: 1, concept_id: params["concept_id"])
  #     return
  #   else
  #     @user_review = @collection_record.reviews.where(user: current_user).first
  #     @user_review.review_state = 0
  #     @user_review.review_completion_date = nil
  #     @user_review.save!
  #   end

  #   flash[:notice] = "User Comments have been saved"
    redirect_to review_path(id: params["id"], section_index: params["section_index"])
  end


end