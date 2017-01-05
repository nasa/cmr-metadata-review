class CurationController < ApplicationController

PROVIDERS = ['PODAAC', 'SEDAC', 'OB_DAAC', 'ORNL_DAAC', 'NSIDC_ECS', 'LAADS',
            'LPDAAC_ECS', 'GES_DISC','CDDIS', 'LARC_ASDC','ASF','GHRC'
            ]

  def home
    byebug

    #ingested records that do not have two completed reviews
    @user_open_ingests = CollectionRecord.find_by_sql("select * from collection_ingests inner join collection_records on collection_records.id = collection_ingests.collection_record_id where user_id = #{current_user.id} and closed = false")
    
    #unfinished review records
    @user_open_reviews = CollectionRecord.find_by_sql("select * from collection_reviews inner join collection_records on collection_records.id = collection_reviews.collection_record_id where user_id = 1 and review_state = 0")

    #all records that do not have a completed review by the user
    @user_available_reviews = CollectionRecord.find_by_sql("with completed_reviews as (select * from collection_reviews where user_id=1 and review_state=1) select * from collection_records left outer join completed_reviews on collection_records.id = completed_reviews.collection_record_id where completed_reviews.collection_record_id is null")

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
      raw_xml = HTTParty.get("https://cmr.earthdata.nasa.gov/search/collections.echo10?provider=#{@provider}&keyword=?*#{@free_text}?*&page_size=#{@page_size}&page_num=#{@curr_page}").parsed_response
      @search_results = Hash.from_xml(raw_xml)["results"]
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

    if @granule_results["hits"].to_i == 0
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
        flash[:error] = 'The selected record has already been ingested for review'
      end 
    else

    end

    redirect_to curation_home_path
  end

end