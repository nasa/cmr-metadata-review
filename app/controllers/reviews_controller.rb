class ReviewsController < ApplicationController
  include ReviewsHelper

  def show
    record = Record.find_by id: params[:id]
    section_index = params["section_index"]

    @marked_done = record.closed

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

    @bubble_data = record.section_bubble_data(0)

    @section_titles = record.section_titles(section_index)
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

    review = Review.find_by id: params["review"]["id"]

    review.review_completion_date = DateTime.now
    review.comment = params["review"]["comment"]
    review.review_state = 1
    review.save

    redirect_to record_path(id: params["review"]["record_id"])
  end


end