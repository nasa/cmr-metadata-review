class ReviewsController < ApplicationController
  include ReviewsHelper

  def show
    record = Record.find_by id: params[:id]
    section_index = params["section_index"]

    @marked_done = record.closed
    @user_has_closed_review = record.reviews.where(user_id: current_user.id, review_state: 1).any?

    @collection_record = Record.find_by id: params[:id] 
    @long_name = @collection_record.long_name
    @short_name = @collection_record.short_name

    @navigation_list = Record::COLLECTION_SECTIONS


    @record_comments = @collection_record.comments
    # @user_comment = @record_comments.select { |comment| comment.user_id == current_user.id }

    # @other_users_comments = @record_comments.select { |comment| (comment.user_id != current_user.id && comment.user_id != -1) }
    # @other_users_comments_count = @other_users_comments.length

    @script_comment = @record_comments.select { |comment| comment.user_id == -1 }.first
    if @script_comment
      @script_comment = JSON.parse(@script_comment.rawJSON)
    end

    # #a boolean test to determine if any review exists (should replace with review??)
    # if @user_comment.empty?
    #   @collection_record.add_review(current_user.id)
    #   @collection_record.add_flag(current_user.id)
    #   @collection_record.add_comment(current_user.id)
    # end

    # @user_flag = Flag.where(user: current_user, record: @collection_record).first
    # @user_review = Review.where(user: current_user, record: @collection_record).first

    # if @user_review.review_state == 1
    #   @review_complete = "checked"
    # else 
    #   @review_complete = ""
    # end

    @bubble_data = record.section_bubble_data(0)

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
    record = Record.find_by id: params["id"]
    if !record.color_coding_complete
      #add redirect here with error in final version
    end

    review = Review.where(user: current_user, record_id: params["id"]).first
    comment = params["review_comment"]
    if review.nil?
      review = Review.new(user: current_user, record_id: params["id"], review_completion_date: DateTime.now, review_state: 1, comment: comment)
    end

    review.comment = comment
    review.save

    redirect_to record_path(id: params["id"])
  end


end