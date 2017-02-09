class ReviewsController < ApplicationController
  include ReviewsHelper

  def show
    record = Record.find_by id: params[:id]
    section_index = params["section_index"].to_i



    @marked_done = record.closed
    @user_has_closed_review = record.reviews.where(user_id: current_user.id, review_state: 1).any?

    @collection_record = Record.find_by id: params[:id] 
    @long_name = @collection_record.long_name
    @short_name = @collection_record.short_name

    @navigation_list = Record::COLLECTION_SECTIONS


    @record_comments = @collection_record.comments

    @script_comment = @record_comments.select { |comment| comment.user_id == -1 }.first
    if @script_comment
      @script_comment = JSON.parse(@script_comment.rawJSON)
    end


    @discussions = record.discussions

    @section_titles = record.sections[section_index][1]

    @bubble_data = []
    bubble_map = record.bubble_map
    @section_titles.each do |title|
        @bubble_data.push(bubble_map[title])
    end

    @flagged_by_script = record.binary_script_values
    @script_values = record.script_values
    @previous_values = nil
    @current_values = record.values
    @flags = record.get_row("flag").values
    @recommendations = record.get_row("recommendation").values
    @second_opinions = record.get_row("second_opinion").values

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