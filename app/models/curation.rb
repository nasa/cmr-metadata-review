class Curation
  ANY_KEYWORD = 'Any'
  PROVIDERS = [ANY_KEYWORD, 'PODAAC', 'SEDAC', 'OB_DAAC', 'ORNL_DAAC', 'NSIDC_ECS', 'LAADS',
              'LPDAAC_ECS', 'GES_DISC','CDDIS', 'LARC_ASDC','ASF','GHRC'
              ]


  def self.user_collection_ingests(user)
    CollectionRecord.find_by_sql("select * from collection_ingests inner join collection_records on collection_records.id = collection_ingests.collection_record_id where collection_ingests.user_id=#{user.id}")
  end

  def self.user_open_collection_reviews(user)
    user.collection_reviews.where(review_state: 0)
  end

  def self.user_available_collection_review(user)
    CollectionRecord.find_by_sql("with completed_reviews as (select * from collection_reviews where user_id=#{user.id} and review_state=1) select * from collection_records left outer join completed_reviews on collection_records.id = completed_reviews.collection_record_id where completed_reviews.collection_record_id is null")
  end

  def self.provider_select_list
    provider_select_list = []
    PROVIDERS.each do |provider|
      provider_select_list.push([provider, provider])
    end
    provider_select_list  
  end

  def self.homepage_collection_search_results(provider, free_text, user)
    if free_text
      search_results = Curation.user_available_collection_review(user).select { |record| ((record.concept_id.include? free_text) || (record.short_name.include? free_text)) }
      unless provider.nil? || provider == ANY_KEYWORD
        search_results = search_results.select { |record| (record.concept_id.include? provider) }
      end
      search_results
    else
      []
    end
  end

  def self.collection_search(free_text, provider = ANY_KEYWORD, curr_page)
    unless curr_page
      curr_page = "1"
    end

    page_size = 10
    search_iterator = []

    if free_text
      query_text = "https://cmr.earthdata.nasa.gov/search/collections.echo10?keyword=?*#{free_text}?*&page_size=#{page_size}&page_num=#{curr_page}"

      #cmr does not accept first character wildcards for some reason, so remove char and retry query
      query_text_first_char = "https://cmr.earthdata.nasa.gov/search/collections.echo10?keyword=#{free_text}?*&page_size=#{page_size}&page_num=#{curr_page}"
      unless provider == ANY_KEYWORD
        query_text = query_text + "&provider=#{provider}"
        query_text_first_char = query_text_first_char + "&provider=#{provider}"
      end

      raw_xml = HTTParty.get(query_text).parsed_response
      search_results = Hash.from_xml(raw_xml)["results"]

      #rerun query with first wildcard removed
      if search_results["hits"].to_i == 0
        raw_xml = HTTParty.get(query_text_first_char).parsed_response
        search_results = Hash.from_xml(raw_xml)["results"]
      end

      collection_count = search_results["hits"].to_i

      if search_results["hits"].to_i > 1
        search_iterator = search_results["result"]
      elsif search_results["hits"].to_i == 1
        search_iterator = [search_results["result"]]
      else
        search_iterator = []
      end
    end

    return search_iterator, collection_count
  end


  def self.collection_data(concept_id)
    collection_xml = HTTParty.get("https://cmr.earthdata.nasa.gov/search/collections.echo10?concept_id=#{concept_id}").parsed_response
    collection_results = Hash.from_xml(collection_xml)["results"]
    collection_results["result"]
  end

  def self.granule_list_from_collection(concept_id, page_num = 1)
    granule_xml = HTTParty.get("https://cmr.earthdata.nasa.gov/search/granules.echo10?concept_id=#{concept_id}&page_size=10&page_num=#{page_num}").parsed_response
    Hash.from_xml(granule_xml)["results"]
  end
end