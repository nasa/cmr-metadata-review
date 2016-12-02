class GranuleCopy
  include Mongoid::Document
  include Mongoid::Timestamps

  field :data, type: Hash, default: {}

  embedded_in :granule_stat
end
