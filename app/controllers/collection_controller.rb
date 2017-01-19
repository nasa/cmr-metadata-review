class CollectionController < ApplicationController

  def show
    @concept_id = params["concept_id"]
    if !@concept_id
      flash[:error] = "No concept_id provided to find record details"
      redirect_to curation_home_path
    end

    collection = Collection.find_by(concept_id: @concept_id)
    @collection_records = collection.records.order(:revision_id).reverse_order

    @granule_objects = Granule.where(collection: collection)
    # @granule_records = granule_objects.map { |granule|}
  end

  def search
    @search_iterator, @collection_count = Cmr.collection_search(params["free_text"], params["provider"], params["curr_page"])
    @free_text = params["free_text"]
    @provider = params["provider"]
    @curr_page = params["curr_page"]
    @provider_select_list = provider_select_list
  end

  def new
    collection_data = Cmr.get_collection(params["concept_id"])
    @concept_id = collection_data["concept_id"]
    @revision_id = collection_data["revision_id"]
    @short_name = collection_data["Collection"]["ShortName"]

    @already_ingested = Collection.record_exists?(@concept_id, @revision_id)
    @granule_count = Cmr.collection_granule_count(@concept_id)
  end

  #this is a behemoth method, but it does several things
  #creates and saves collection record, all related granule records and ingests
  #runs evaluation script over collection record and all granules and saves results as comments
  def create
    concept_id = params["concept_id"]
    revision_id = params["revision_id"]

    if Collection.record_exists?(concept_id, revision_id)
      redirect_to curation_home_path
      flash[:alert] = 'This collection has already been ingested into the system'
      return
    end

    # begin 
      collection_data = Cmr.get_collection(concept_id)
      short_name = collection_data["Collection"]["ShortName"]
      ingest_time = DateTime.now
      #nil gets turned into 0
      granules_count = params["granulesCount"].to_i
      #finding parent collection
      collection_object = Collection.find_or_create_by(concept_id: concept_id, short_name: short_name)
      #creating collection record related objects
      new_collection_record = Record.new(recordable: collection_object, revision_id: revision_id, closed: false, rawJSON: collection_data.to_json)
      ingest_record = Ingest.new(record: new_collection_record, user: current_user, date_ingested: ingest_time)

      #returns a list of granule data
      granules_to_save = Cmr.random_granules_from_collection(concept_id, granules_count)
      #replacing the data with new granule & record & ingest objects
      granules_to_save.map! do |granule_data| 
        granule_object = Granule.new(concept_id: granule_data["concept_id"], collection: collection_object)
        new_granule_record = Record.new(recordable: granule_object, revision_id: granule_data["revision_id"], closed: false, rawJSON: granule_data.to_json)
        granule_ingest = Ingest.new(record: new_granule_record, user: current_user, date_ingested: ingest_time)
        [ granule_object, new_granule_record, granule_ingest ]
      end 

      #saving all the related collection and granule data in a combined transaction
      ActiveRecord::Base.transaction do
        new_collection_record.save!
        ingest_record.save!
        granules_to_save.flatten.each { |savable_object| savable_object.save! }
      end


      #getting list of records for script
      granule_records = granules_to_save.select { |savable_object| savable_object.is_a?(Record) }

      new_collection_record.evaluate_script
      granule_records.each do |record|
        record.evaluate_script
      end

      flash[:notice] = "The selected collection has been successfully ingested into the system"
    # rescue
      flash[:alert] = 'There was an error ingesting the record into the system'
    # end
      
    redirect_to curation_home_path
  end

  def review
    @concept_id = params["concept_id"]
    @revision_id = params["revision_id"]

    if !(@concept_id || @revision_id)
      flash[:error] = "Missing the concept_id or revision_id to Locate review"
      redirect_to curation_home_path
    end

    @collection_record = Collection.find_record(@concept_id, @revision_id)
    @record_comments = @collection_record.comments
    @user_comment = @record_comments.select { |comment| comment.user_id == current_user.id }
    @other_users_comments = @record_comments.select { |comment| (comment.user_id != current_user.id && comment.user_id != -1) }

    @script_comment = @record_comments.select { |comment| comment.user_id == -1 }.first

    if @script_comment
      @script_comment = JSON.parse(@script_comment.rawJSON)
    end

    if @user_comment.empty?
      @collection_record.add_comment(current_user.id)
      #grabbing the newly made comment
      @user_comment = Comment.where(user: current_user, record: @collection_record).first
    else
      @user_comment = @user_comment.first
    end

    @user_comment_contents = JSON.parse(@user_comment.rawJSON)

    @display_list = []

    JSON.parse(@collection_record.rawJSON)["Collection"].each do |key, value|
      if value.is_a?(String) 
        @display_list.push({key: key, value: value, script: @script_comment[key], reviewer: @user_comment_contents["Collection"][key]})
      end
    end

  end

end