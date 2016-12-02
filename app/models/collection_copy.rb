class CollectionCopy
  include Mongoid::Document
  include Mongoid::Timestamps

  field :data, type: Hash, default: {}

  embedded_in :collection_stat
end
