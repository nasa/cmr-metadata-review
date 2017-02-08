class ReviewsController < ApplicationController
  include ReviewsHelper

  def show
    record = Record.find_by id: params[:id]
    section_index = params["section_index"]

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
    @flags = record.get_row("flag").values
    @recommendations = record.get_row("recommendation").values
    @second_opinions = record.get_row("second_opinion").values

    @color_codes = record.color_codes

  end




  def update
    record = Record.find_by id: params[:id]
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

    redirect_to review_path(id: params["id"], section_index: params["section_index"])
  end


end