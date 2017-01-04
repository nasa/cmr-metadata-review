class CurationController < ApplicationController

  def home

    if params["curr_page"]
      @curr_page = params["curr_page"]
    else
      @curr_page = "1"
    end

    @page_size = 10

    if params["free_text"]
      @free_text = params["free_text"]
      raw_xml = HTTParty.get("https://cmr.earthdata.nasa.gov/search/collections.echo10?keyword=?*#{@free_text}?*&page_size=#{@page_size}&page_num=#{@curr_page}").parsed_response
      @search_results = Hash.from_xml(raw_xml)["results"]
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