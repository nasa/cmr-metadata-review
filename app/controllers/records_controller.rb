class RecordsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_curation

  def refresh
    # a list of records added in update in format of
    # [["concept_id1", "revision_id1"], ["concept_id2", "revision_id2"]]
    total_added_records = []
    total_added_records = Cmr.update_collections(current_user)

    flash[:notice] = Cmr.format_added_records_list(total_added_records).html_safe
    redirect_to (request.referrer || home_path)
  end

  def show
    @record = Record.find_by id: params["id"]
    if @record.nil?
      redirect_to home_path
      return
    end

    @record_sections = @record.sections
    @bubble_data = @record.bubble_map

    @review = Review.where(user: current_user, record_id: params["id"]).first
    if @review.nil?
        @review = Review.new(user: current_user, record_id: params["id"], review_state: 0)
        @review.save
    end

    @reviews = (@record.reviews.select {|review| review.completed?}).sort_by(&:review_completion_date)
    @user_review = @record.review(current_user.id)

    @completed_records = (@reviews.map {|item| item.review_state == 1 ? 1:0}).reduce(0) {|sum, item| sum + item }
    @marked_done = @record.closed

    if ENV['SIT_SKIP_DONE_CHECK'] == 'true'
      @color_coding_complete = true
      @has_enough_reviews = true
      @no_second_opinions = true
    else
      @color_coding_complete = @record.color_coding_complete?
      @has_enough_reviews = @record.has_enough_reviews?
      @no_second_opinions = @record.no_second_opinions?
    end
  end

  def complete
    record = Record.find_by id: params["id"]
    if record.nil?
      redirect_to home_path
      return
    end
    
    #checking that all bubbles are filled in
    if !record.color_coding_complete? || !record.has_enough_reviews? || !record.no_second_opinions?
      redirect_to record_path(record)
      return
    end

    record.close

    redirect_to collection_path(id:1, concept_id: record.recordable.concept_id)
  end

  def update
    record = Record.find_by id: params[:id]
    if record.nil?
      redirect_to home_path
      return
    end

    if record.closed?
      redirect_to review_path(id: params["id"], section_index: params["section_index"])
      return 
    end

    section_index = params["section_index"].to_i

    if section_index.nil?
      redirect_to home_path
      return
    end

    section_titles = record.sections[section_index][1]


    begin
      record.update_recommendations(params["recommendation"])

      record.update_colors(params["color_code"])

      opinion_values = record.get_opinions
      section_titles.each do |title|
        opinion_values[title] = false
      end

      if params["opinion"]
        params["opinion"].each do |key, value|
            if value == "on"
              opinion_values[key] = true
            end
        end
      end
      record.update_opinions(opinion_values)
    rescue
      flash[:error] = "Values were not updated in the system.  Please resave changes."
    end

    if params["discussion"]
      params["discussion"].each do |key, value|
        if value != ""
          message = Discussion.new(record: record, user: current_user, column_name: key, date: DateTime.now, comment: value)
          message.save
        end
      end
    end 

    redirect_to review_path(id: params["id"], section_index: params["redirect_index"])
  end

end