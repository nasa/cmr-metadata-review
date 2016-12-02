class DaacStat
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :collections_count, type: Integer, default: 0
  field :granules_count, type: Integer, default: 0
  field :checked_records, type: Integer, default: 0
  field :resolved_records, type: Integer, default: 0

  has_many :collection_stats

  validates :name, presence: true, uniqueness: true

  def concept_ids
    self.collection_stats.pluck(:concept_id)
  end

  def granule_ids
    GranuleStat.where(:granule_id.in => concept_ids).pluck(:granule_id)
  end

  def reviewed_count
    ReviewDetail.or(
      :concept_id.in => concept_ids,
      :granule_id.in => granule_ids
    ).reviewed.count
  end

  def total_records
    self.collection_stat_ids.count * 2
  end
end