class CollectionController < ApplicationController

  def show
    @concept_id = params["concept_id"]
    if !@concept_id
      flash[:error] = "No concept_id provided to find record details"
      redirect_to curation_home_path
    end

    @collection_records = CollectionRecord.where(concept_id: @concept_id).order(:version_id).reverse_order
  end

  def search
    @search_iterator, @collection_count = Curation.collection_search(params["free_text"], params["provider"], params["curr_page"])
    @free_text = params["free_text"]
    @provider = params["provider"]
    @curr_page = params["curr_page"]
    @provider_select_list = Curation.provider_select_list
  end

  def new
    @collection_data = Curation.collection_data(params["concept_id"])
    @already_ingested = CollectionRecord.ingested?(@collection_data["concept_id"], @collection_data["revision_id"])
    @granule_results = Curation.granule_list_from_collection(params["concept_id"])
  end

  def create
    byebug
    concept_id = params["concept_id"]
    revision_id = params["revision_id"]
    granules_Count = params["granulesCount"]

    #need to add revision id to this??
    collection_data = Cmr.get_collection(concept_id)
    short_name = collection_data["Collection"]["ShortName"]
    Collection.find_or_create_by(concept_id: concept_id, short_name: short_name)


    ingest_success = CollectionRecord.ingest_with_granules(params["concept_id"], params["revision_id"], params["granulesCount"], current_user)

    if ingest_success
      collection = CollectionRecord.where(concept_id: params["concept_id"], version_id: params["revision_id"]).first
      collection_script_success = collection.evaluate_script

      granules_list = GranuleRecord.where(collection_concept_id: params["concept_id"])
      granule_script_success = true
      #filter for those with no automated check
      granules_list = granules_list.select { |granule| !(granule.reviews.where(user_id: -1).any?) }
      granules_list.each { |granule| 
        script_result = granule.evaluate_script; 
        granule_script_success = script_result if !script_result }

      script_results_phrase = ", the automated reviews were not completed for all collections and granules"
      if collection_script_success && granule_script_success
        script_results_phrase = ", and all automated scripts ran successfully"
      end
    end

    if ingest_success
      flash[:notice] = "The selected collection has been successfully ingested into the system" + script_results_phrase.to_s
    else 
      flash[:alert] = 'There was an error ingesting the record into the system' + script_results_phrase.to_s
    end
    redirect_to curation_home_path
  end

  def review
    @concept_id = params["concept_id"]
    @revision_id = params["revision_id"]

    if !(@concept_id || @revision_id)
      flash[:error] = "Missing the concept_id or revision_id to Locate review"
      redirect_to curation_home_path
    end

    @collection_record = CollectionRecord.where(concept_id: @concept_id, version_id: @revision_id).first
    @record_comments = @collection_record.collection_comments
    @user_comment = @record_comments.select { |comment| comment.user_id == current_user.id }
    @script_comment = @record_comments.select { |comment| comment.user_id == -1 }.first

    if @script_comment
      @script_comment = JSON.parse(@script_comment.rawJSON)
    end

    if @user_comment.empty?
      @collection_record.add_comment(current_user)
      #grabbing the newly made comment
      @user_comment = CollectionComment.where(user_id: current_user.id, collection_record_id: @collection_record.id).first
    else
      @user_comment = @user_comment.first
    end

    @user_comment_contents = JSON.parse(@user_comment.rawJSON)

    @display_list = []
    JSON.parse(@collection_record.rawJSON)["Collection"].each do |key, value|
      if value.is_a?(String) 
        @display_list.push([key, value, @script_comment[key], @user_comment_contents[key]])
      end
    end

  end

end