class ReviewsController < ApplicationController
  include ReviewsHelper

  before_action :authenticate_user!
  before_action :ensure_curation

  def get_raw_metadata(concept_id, revision_id, format)
    url = "#{Cmr.get_cmr_base_url}/search/concepts/#{concept_id}#{revision_id.nil? ? "" : "/#{revision_id}"}#{format.nil? ? "" : ".#{format}"}"
    Cmr.cmr_request(url).body
  end

  def json
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
    metadata = JSON.parse(get_raw_metadata(@record.recordable.concept_id, @record.revision_id, @record.format))
    review_data = @record.record_datas
    result = { metadata: metadata, review_data: review_data  }
    render json: result
  end

  def save_review
    
  end

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
    record_id = params['review']['record_id']
    record = Record.find_by id: record_id
    messages = []

    unless record.color_coding_complete?
      messages << 'Note, not all columns have been flagged with a color, be sure this is done before marking this review complete.'
    end
    unless record.no_second_opinions?
      messages << 'Note, some columns still need a second opinion review.  Please clear all second opinion flags before releasing this record to the daac.'
    end
    if messages.any?
      flash[:alert] = messages.join('<br>').html_safe
    end

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

  def update_review_comment
    review = Review.find_by(id: params[:id])
    review.update(review_comment: params[:review_comment])
    redirect_to record_path(id: review.record_id)
  end

  def update_report_comment
    review = Review.find_by(id: params[:id])
    review.update(report_comment: params[:report_comment])
    redirect_to record_path(id: review.record_id)
  end

  private

  def review_params
    params.require(:review).permit(:user_id, :record_id, :review_state, :report_comment, :review_comment)
  end

end
