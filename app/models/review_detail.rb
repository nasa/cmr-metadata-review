class ReviewDetail
  include Mongoid::Document
  include Mongoid::Timestamps

  REVIEWING = 'reviewing'
  REVIEWED = 'reviewed'

  belongs_to :user
  belongs_to :granule_stat, class_name: 'GranuleStat'
  belongs_to :collection_stat, class_name: 'CollectionStat'

  field :reviewed_at, type: DateTime
  field :status, type: String, default: REVIEWING
  field :started_at, type: DateTime

  scope :reviewed, -> { where(status: REVIEWED) }
  scope :reviewing, -> { where(status: REVIEWING) }

  def review
    if self.status == REVIEWING
      self.status = REVIEWED
      self.reviewed_at = DateTime.now
      self.save
      update_daac_stat
    end
  end

  def update_daac_stat
    collection_stat = self.collection_stat || self.granule_stats.collection_stat
    daac_stat = collection_stat.daac_stat
    daac_stat.update_attribute(:checked_records, daac_stat.checked_records + 1)
  end

  def data
    {
      user: self.user.email,
      start_time: self.started_at,
      end_time: self.reviewed_at,
      status: self.status
    }
  end

  def self.histories(collection_id:)
    review_details = self.any_of(
                      { collection_stat_id: collection_id },
                      { granule_stat_id: collection_id }
                    )
    review_details.map(&:data)
  end
end