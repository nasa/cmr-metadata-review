class GatherDaacDetails
  include Sidekiq::Worker

  def perform
    CacheData.all # cache all keyword list in local.
    CollectionsRetriever::PROVIDERS.each do |provider|
      coll_retriever = CollectionsRetriever.new(provider, per_page = 1)
      coll_retriever.store_collections_locally
      coll_retriever = nil # better memory management
    end
  end
end