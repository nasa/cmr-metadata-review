class CurationController < ApplicationController
  ANY_KEYWORD = 'Any'

  PROVIDERS = [ANY_KEYWORD, 'PODAAC', 'SEDAC', 'OB_DAAC', 'ORNL_DAAC', 'NSIDC_ECS', 'LAADS',
              'LPDAAC_ECS', 'GES_DISC','CDDIS', 'LARC_ASDC','ASF','GHRC'
              ]

  before_filter :ensure_curate_access            

  #ensuring that only curators can access the information
  def ensure_curate_access
    authorize! :access, :curate
  end

  def home
    #ingested records by user
    @user_open_ingests = CollectionRecord.find_by_sql("select * from collection_ingests inner join collection_records on collection_records.id = collection_ingests.collection_record_id where collection_ingests.user_id=#{current_user.id}")
    
    #unfinished review records
    @user_open_reviews = CollectionRecord.find_by_sql("select * from collection_reviews inner join collection_records on collection_records.id = collection_reviews.collection_record_id where user_id=#{current_user.id} and review_state=0")

    #all records that do not have a completed review by the user
    @user_available_reviews = CollectionRecord.find_by_sql("with completed_reviews as (select * from collection_reviews where user_id=#{current_user.id} and review_state=1) select * from collection_records left outer join completed_reviews on collection_records.id = completed_reviews.collection_record_id where completed_reviews.collection_record_id is null")

    if params["free_text"]
      @free_text = params["free_text"]
      @provider = params["provider"]


      @search_results = @user_available_reviews.select { |record| ((record.concept_id.include? @free_text) || (record.short_name.include? @free_text)) }
      unless @provider == ANY_KEYWORD
        @search_results = @search_results.select { |record| (record.concept_id.include? @provider) }
      end

      
    end

    @provider_select_list = []
    PROVIDERS.each do |provider|
      @provider_select_list.push([provider, provider])
    end  


  end

  def search

    if params["curr_page"]
      @curr_page = params["curr_page"]
    else
      @curr_page = "1"
    end

    @page_size = 10

    if params["free_text"]
      @free_text = params["free_text"]
      @provider = params["provider"]

      query_text = "https://cmr.earthdata.nasa.gov/search/collections.echo10?keyword=?*#{@free_text}?*&page_size=#{@page_size}&page_num=#{@curr_page}"

      #cmr does not accept first character wildcards for some reason, so remove char and retry query
      query_text_first_char = "https://cmr.earthdata.nasa.gov/search/collections.echo10?keyword=#{@free_text}?*&page_size=#{@page_size}&page_num=#{@curr_page}"
      unless @provider == ANY_KEYWORD
        query_text = query_text + "&provider=#{@provider}"
        query_text_first_char = query_text_first_char + "&provider=#{@provider}"
      end

      raw_xml = HTTParty.get(query_text).parsed_response
      @search_results = Hash.from_xml(raw_xml)["results"]

      #rerun query with first wildcard removed
      if @search_results["hits"].to_i == 0
        raw_xml = HTTParty.get(query_text_first_char).parsed_response
        @search_results = Hash.from_xml(raw_xml)["results"]
      end

      if @search_results["hits"].to_i > 1
        @search_iterator = @search_results["result"]
      else
        @search_iterator = [@search_results["result"]]
      end

    end

    @provider_select_list = []
    PROVIDERS.each do |provider|
      @provider_select_list.push([provider, provider])
    end                

  end

  def ingest_details
    @collection_concept_id = params["concept_id"]
    collection_xml = HTTParty.get("https://cmr.earthdata.nasa.gov/search/collections.echo10?concept_id=#{@collection_concept_id}").parsed_response
    @collection_results = Hash.from_xml(collection_xml)["results"]
    @collection_data = @collection_results["result"]

      concept_id = @collection_data["concept_id"]
      shortname = @collection_data["Collection"]["ShortName"]
      version_id = @collection_data["revision_id"]
      if CollectionRecord.where(concept_id: concept_id, version_id: version_id).any?
        @already_ingested = true
      end

    granule_xml = HTTParty.get("https://cmr.earthdata.nasa.gov/search/granules.echo10?concept_id=#{@collection_concept_id}").parsed_response
    @granule_results = Hash.from_xml(granule_xml)["results"]
  end

  def ingest
    if !current_user
      redirect_to :root
      return
    end

    @collection_concept_id = params["concept_id"]
    collection_xml = HTTParty.get("https://cmr.earthdata.nasa.gov/search/collections.echo10?concept_id=#{@collection_concept_id}").parsed_response
    @collection_results = Hash.from_xml(collection_xml)["results"]
    @collection_data = @collection_results["result"]

    granule_xml = HTTParty.get("https://cmr.earthdata.nasa.gov/search/granules.echo10?concept_id=#{@collection_concept_id}").parsed_response
    @granule_results = Hash.from_xml(granule_xml)["results"]

  
    concept_id = @collection_data["concept_id"]
    shortname = @collection_data["Collection"]["ShortName"]
    version_id = @collection_data["revision_id"]
    unless CollectionRecord.where(concept_id: concept_id, version_id: version_id).any?
      record = CollectionRecord.new
      record.concept_id = concept_id
      record.short_name = shortname
      record.version_id = version_id
      record.closed = false
      record.rawJSON = @collection_data.to_json
      record.save

      ingest_record = CollectionIngest.new
      ingest_record.collection_record_id = record.id
      ingest_record.user_id = current_user.id
      ingest_record.date_ingested = DateTime.now
      ingest_record.save

    else
      flash[:alert] = 'The selected record has already been ingested for review'
    end 

    if @granule_results["hits"].to_i == 0
      
    else

    end
    flash[:notice] = "The selected collection has been successfully ingested into the system"
    redirect_to curation_home_path
  end

end