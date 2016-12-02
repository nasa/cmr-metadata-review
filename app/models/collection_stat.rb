class CollectionStat
  include Mongoid::Document
  include Mongoid::Timestamps

  # attr_accessible :concept_id, :entry_title, :granule_count

  field :concept_id, type: String
  field :entry_title, type: String
  field :granule_count, type: Integer
  has_many :review_details

  field :status, type: String

  belongs_to :daac_stat
  has_one :granule_stat

  delegate :name, to: :daac_stat, prefix: :daac, allow_nil: false

  validates :concept_id, presence: true, uniqueness: true

  embeds_one :previous_version, class_name: 'CollectionCopy', autobuild: true
  embeds_one :recommended, class_name: 'CollectionCopy', autobuild: true
  embeds_one :reasons, class_name: 'CollectionCopy', autobuild: true
  embeds_one :latest_version, class_name: 'CollectionCopy', autobuild: true

  def assign_random_granule
    granule_retriever = GranuleRetriever.new(self.daac_name, self.concept_id)
    granule_detail = granule_retriever.choose_granule_randomly
    granule_stat = GranuleStat.create(collection_stat: self, granule_id: granule_detail['id'])
    granule_retriever.store_granule_locally(granule_stat)
  end
end
