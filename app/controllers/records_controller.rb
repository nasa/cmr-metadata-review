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

    recommendations, recommendations_users = record.recommendation_values
    params.each do |key, value|
      if key =~ /recommendation_(.*)/
        if recommendations[$1] != value
          recommendations[$1] = value
          recommendations_users[$1] = []
          recommendations_users[$1].push(current_user.email)
          recommendations_users[$1].push(DateTime.now)
        end
      end
    end
    record.update_recommendation(recommendations, recommendations_users)

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
    flags_hash = record.flag_values
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

    record.update_flag_values(flags_hash)


    opinion_values = record.second_opinion_values
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

    record.update_opinion_values(opinion_values)

  #   @collection_record = Collection.find_record(params["concept_id"], params["revision_id"])

  #   #updating comment text
  #   @user_comment = @collection_record.comments.where(user: current_user).first
  #   new_comment = JSON.parse(@user_comment.rawJSON)
  #   params.each do |key, value|
  #     if key =~ /user_(.*)/
  #       new_comment[$1] = value
  #     end
  #   end
  #   @user_comment.rawJSON = new_comment.to_json
  #   @user_comment.save!


  #   #updating flags
  #   @user_flags = @collection_record.flags.where(user: current_user).first
  #   new_flags = JSON.parse(@user_flags.rawJSON)
  #   params.each do |key, value|
  #     if key =~ /userflag_(.*)/
  #       new_flags[$1] = value
  #     end
  #   end
  #   @user_flags.rawJSON = new_flags.to_json
  #   @user_flags.save!


  #   #updating review
  #   if params["userreviewcheck"] == "done"
  #     @user_review = @collection_record.reviews.where(user: current_user).first
  #     if @user_review.review_state == 0
  #       @user_review.review_state = 1
  #       @user_review.review_completion_date = DateTime.now
  #       @user_review.save!
  #     end

  #     flash[:notice] = "User Review has been saved"
  #     redirect_to collection_path(id: 1, concept_id: params["concept_id"])
  #     return
  #   else
  #     @user_review = @collection_record.reviews.where(user: current_user).first
  #     @user_review.review_state = 0
  #     @user_review.review_completion_date = nil
  #     @user_review.save!
  #   end

  #   flash[:notice] = "User Comments have been saved"
    redirect_to review_path(id: params["id"], section_index: params["section_index"])
  end

end