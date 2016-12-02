class CollectionsRetriever
  include Flattener
  require 'httparty'
  XML_REGEX = /(<(\w+)[^>]*>.*<\/\2>|<(\w+)[^>]*\/>)/
  PROVIDERS = [
    'PODAAC', 'SEDAC', 'OB_DAAC', 'ORNL_DAAC', 'NSIDC_ECS', 'LAADS',
    'LPDAAC_ECS', 'GES_DISC','CDDIS', 'LARC_ASDC','ASF','GHRC'
  ]

  URL = 'https://cmr.earthdata.nasa.gov/search/provider_holdings.json'
  CONCEPT_URL = 'https://cmr.earthdata.nasa.gov/search/collections'

  attr_accessor :provider, :daac, :page_size, :url, :total_records, :collections

  def initialize(provider, page_size = 2000)
    @provider = provider
    @url = "#{URL}?provider_id=#{provider}"
    @total_records = {}
    @collections = []
  end

  def store_collections_locally
    @daac = DaacStat.find_or_create_by(name: provider)
    retrieve_collections
    daac.update_attributes(total_records)
    collections.each do |stat|
      concept_id = stat['concept-id']
      collection_stat = CollectionStat.find_or_create_by(concept_id: concept_id)
      collection_stat.update_attributes(
                        daac_stat: daac,
                        entry_title: stat['entry-title'],
                        granule_count: stat['granule-count']
                      )
      response = Hash.from_xml(HTTParty.get("#{CONCEPT_URL}?concept_id=#{concept_id}").body)
      revision_id = response['results']['references']['reference']['revision_id']
      retrieve_url = response['results']['references']['reference']['location']
      collection = prepare_collection_from(retrieve_url)
      collection['revision_id'] = revision_id
      # fields = $redis.lrange('collection:fields', 0, -1)
      # data = collection.slice(*fields)
      collection_stat.latest_version.data = collection
      if collection_stat.previous_version.blank?
        collection_stat.previous_version.data = data
        collection_stat.previous_version.save
      end
      collection_stat.latest_version.save
      collection_stat.save
    end
  end

  private

  def prepare_collection_from(retrieve_url)
    @url = retrieve_url
    body = retrieve.body
    collection = if body.match(XML_REGEX)
                   Hash.from_xml(body)
                 else
                   JSON.parse(body) rescue body
                 end
    flatten(collection['Collection'] || {})
  end

  def retrieve
    HTTParty.get(url)
  end

  def retrieve_collections
    return daac if collections.present?
    coll = retrieve
    if coll.code == 200
      counts = coll.to_hash
      @total_records = {
        collections_count: counts['cmr-collection-hits'].first.to_i,
        granules_count: counts['cmr-granule-hits'].first.to_i
      }
      @collections = JSON.parse(coll.body)
    end
  end
end
