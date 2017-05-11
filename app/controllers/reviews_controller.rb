class ReviewsController < ApplicationController
  include ReviewsHelper

  before_filter :authenticate_user!
  before_filter :ensure_curation

  def show
    record = Record.find_by id: params[:id]
    section_index = params["section_index"].to_i

    @marked_done = record.closed

    @collection_record = Record.find_by id: params[:id] 

    @navigation_list = record.sections.map {|section| section[0] }

    @script_comment = @collection_record.get_script_comments

    @discussions = record.discussions

    @section_titles = (record.sections[section_index][1]).sort

    @bubble_data = []
    bubble_map = record.bubble_map
    @section_titles.each do |title|
        unless bubble_map[title].nil?
            @bubble_data.push(bubble_map[title])
        end
    end


    @flagged_by_script = record.binary_script_values
    @script_values = record.script_values
    @previous_values = nil
    @current_values = record.values
    @recommendations = record.get_recommendations
    @second_opinions = record.get_opinions

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