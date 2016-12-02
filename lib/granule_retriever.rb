class GranuleRetriever
  include Flattener
  require 'httparty'

  URL = 'https://cmr.earthdata.nasa.gov/search/granules'
  CONCEPT_URL = 'https://cmr.earthdata.nasa.gov/search/collections'

  attr_accessor :page_size, :url, :granules, :selected_granule

  def initialize(provider, concept_id, page_size = 2000)
    @url = "#{URL}?provider_id=#{provider}&concept_id=#{concept_id}&page_size=2000"
    @granules = []
  end

  def choose_granule_randomly
    retrieve_granules
    @selected_granule = granules.sample
  end

  def store_granule_locally(granule_stat)
    url = selected_granule['location']
    granule = prepare_granule_from(url)
    granule['revision_id'] = selected_granule['revision_id']
    # fields = $redis.lrange('granule:fields', 0, -1)
    # data = granule.slice(*fields)
    granule_stat.location = url
    granule_stat.latest_version.data = granule
    if granule_stat.previous_version.blank?
      granule_stat.previous_version.data = data
      granule_stat.previous_version.save
    end
    granule_stat.latest_version.save
    granule_stat.save
  end

  private

  def prepare_granule_from(retrieve_url)
    @url = retrieve_url
    collection = Hash.from_xml(retrieve.body)
    result = flatten(collection['Granule'])
  end

  def retrieve
    HTTParty.get(url)
  end

  def retrieve_granules
    coll = retrieve
    if coll.code == 200 && coll['results']['references'].present?
      @granules = coll.to_hash['results']['references']['reference']
    end
  end
end
