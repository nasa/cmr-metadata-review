class ReviewsController < ApplicationController
  include ReviewsHelper

  before_filter :authenticate_user!
  before_filter :ensure_curation

  def show
    @record = Record.find_by id: params[:id]

    @marked_done = @record.closed?

    @collection_record = Record.find_by id: params[:id]

    @navigation_list = @record.sections.map {|section| section[0] }

    @script_comment = @collection_record.get_script_comments

    @justification_discussions = @record.discussions.justification
    @feedback_discussions = @record.discussions.feedback

    section_index = params["section_index"].to_i
    section = @record.sections[section_index];

    @section_title = section[0]
    @section_titles = section[1]
    @controlled_notices = @record.controlled_notice_list(@section_titles)

    @bubble_data = []
    bubble_map = @record.bubble_map
    @section_titles.each do |title|
        unless bubble_map[title].nil?
            @bubble_data.push(bubble_map[title])
        end
    end

    @flagged_by_script = @record.binary_script_values
    @script_values = @record.script_values
    @script_values = replace_links(@script_values)

    @previous_values = replace_links(@previous_values)

    @previous_recommendations = @record.previous_recommendations

    @current_values = @record.values
    @current_values = replace_links(@current_values)

    @recommendations = @record.get_recommendations
    @second_opinions = @record.get_opinions
    @feedbacks = @record.get_feedbacks

    @color_codes = @record.color_codes

  end

  def create
    #making sure we dont make duplicate review
    if !Review.where(user_id: params['review']['user_id'].to_i, record_id: params['review']['record_id'].to_i).first.nil?
        redirect_to record_path(id: params['review']['record_id'].to_i)
    end

    new_review = Review.create(review_params)

    redirect_to record_path(id: new_review.record_id)
  end

  def update
    review = Review.find_by id: params["review"]["id"]
    review.update(review_params)

    redirect_to record_path(id: review.record_id)
  end

  private

  def review_params
    params.require(:review).permit(:user_id, :record_id, :review_state, :report_comment, :review_comment)
  end

end
