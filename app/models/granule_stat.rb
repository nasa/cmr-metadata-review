class GranuleStat
  include Mongoid::Document
  include Mongoid::Timestamps

  # attr_accessible :concept_id, :entry_title, :granule_count

  field :granule_id, type: String
  field :location, type: String
  belongs_to :collection_stat
  has_many :review_details

  validates :granule_id, presence: true, uniqueness: true

  embeds_one :previous_version, class_name: 'GranuleCopy', autobuild: true
  embeds_one :recommended, class_name: 'GranuleCopy', autobuild: true
  embeds_one :reasons, class_name: 'GranuleCopy', autobuild: true
  embeds_one :latest_version, class_name: 'GranuleCopy', autobuild: true
end
