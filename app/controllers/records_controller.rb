class RecordsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_curation


  def show
    record = Record.find_by id: params["id"]
    if record.nil?
      redirect_to home_path
      return
    end

    @record_sections = record.sections
    @bubble_data = record.bubble_map

    @review = Review.where(user: current_user, record_id: params["id"]).first
    if @review.nil?
        @review = Review.new(user: current_user, record_id: params["id"], review_state: 0)
        @review.save
    end

    @long_name = record.long_name
    @short_name = record.short_name
    @concept_id = record.concept_id

    @reviews = (record.reviews.select {|review| review.completed?}).sort_by(&:review_completion_date)
    @user_review = record.review(current_user.id)

    @completed_records = (@reviews.map {|item| item.review_state == 1 ? 1:0}).reduce(0) {|sum, item| sum + item }
    @marked_done = record.closed

    @color_coding_complete = record.color_coding_complete?
    @has_enough_reviews = record.has_enough_reviews?
    @no_second_opinions = record.no_second_opinions?
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

    record.get_recommendations.update_partial_values(params["recommendation"])

    record.get_colors.update_partial_values(params["color_code"])


    #flags are stored in a hash => list relationship
    #each hash key is a column of a record
    #each value is a list containing the string names of each checked flag for that key
    #ie JSON.parse(flag_example.rawJSON)["shortName"] == ["accessibility", "usability"]
    flags_hash = record.get_flags.values
    section_titles.each do |title|
      flags_hash[title] = [];
    end

    #example structure of the params
    # "flag"=>{"InsertTime"=>{"Accessibility"=>"on", "Usability"=>"on", "Traceability"=>"on"}, "LastUpdate"=>{"Traceability"=>"on"}}
    if params["flag"]
      params["flag"].each do |field, flag_hash|
        flag_hash.each do |flag, status|
          if status == "on"
            flags_hash[field].push(flag)
          end
        end
      end
    end
    record.get_flags.update_values(flags_hash)


    opinion_values = record.get_opinions.values
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
    record.get_opinions.update_values(opinion_values)

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