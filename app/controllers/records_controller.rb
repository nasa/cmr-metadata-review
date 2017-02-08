class RecordsController < ApplicationController
  def show
    record = Record.find_by id: params["id"]
    @bubble_data = record.section_bubble_data(0)

    @long_name = record.long_name
    @short_name = record.short_name
    @concept_id = record.concept_id

    @reviews = record.reviews.sort_by(&:review_completion_date)
    @user_review = record.review(current_user.id)

    @completed_records = (@reviews.map {|item| item.review_state == 1 ? 1:0}).reduce(0) {|sum, item| sum + item }
    @marked_done = record.closed
  end

  def complete
    record = Record.find_by id: params["id"]
    record.close

    redirect_to collection_path(id:1, concept_id: record.recordable.concept_id)
  end

  def update
    record = Record.find_by id: params[:id]
    if record.closed?
      redirect_to review_path(id: params["id"], section_index: params["section_index"])
      return 
    end

    if record.reviews.where(user_id: current_user.id, review_state: 1).any?
      redirect_to review_path(id: params["id"], section_index: params["section_index"])
      return 
    end

    section_index = params["section_index"]

    recommendations = record.get_row("recommendation").values
    params.each do |key, value|
      if key =~ /recommendation_(.*)/
        recommendations[$1] = value
      end
    end
    record.get_row("recommendation").update_values(recommendations)

    color_codes = record.color_codes
    params.each do |key, value|
      if key =~ /color_code_(.*)/
        color_codes[$1] = value
      end
    end
    record.update_color_codes(color_codes)

    #flags are stored in a hash => list relationship
    #each hash key is a column of a record
    #each value is a list containing the string names of each checked flag for that key
    #ie JSON.parse(flag_example.rawJSON)["shortName"] == ["accessibility", "usability"]
    flags_hash = record.get_row("flag").values
    section_titles = record.section_titles(section_index)
    section_titles.each do |title|
      flags_hash[title] = [];
    end
    params.each do |key, value|
      if key =~ /flag_(.*)_check_(.*)/
        if value == "on"
          flags_hash[$2].push($1)
        end
      end
    end

    record.get_row("flag").update_values(flags_hash)

    opinion_values = record.get_row("second_opinion").values
    section_titles = record.section_titles(section_index)
    section_titles.each do |title|
      opinion_values[title] = false
    end

    params.each do |key, value|
      if key =~ /opinion_check_(.*)/
        if value == "on"
          opinion_values[$1] = true
        end
      end
    end

    record.get_row("second_opinion").update_values(opinion_values)

    params.each do |key, value|
      if key =~ /discussion_(.*)/
        if value != ""
          message = Discussion.new(record: record, user: current_user, column_name: $1, date: DateTime.now, comment: value)
          message.save
        end
      end
    end
    
    redirect_to review_path(id: params["id"], section_index: params["section_index"])
  end

end