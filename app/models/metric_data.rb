# Keeps track of the each metric set type for a set of recordables
class MetricData
  attr_reader :recordables

  IN_PROGRESS_METRICS = [Record::STATE_CLOSED, Record::STATE_IN_DAAC_REVIEW]
  FINISHED_METRICS    = [Record::STATE_FINISHED]
  METRIC_STATES       = IN_PROGRESS_METRICS + FINISHED_METRICS

  def initialize(recordables)
    @recordables = recordables
  end

  def original_metric_set
    @original_metric_set ||= MetricSet.new(original_revisions)
  end

  def updated_metric_set
    @updated_metric_set ||= MetricSet.new(latest_in_progress_revisions)
  end

  def final_metric_set
    @final_metric_set ||= MetricSet.new(final_revisions)
  end

  def original_color_counts
    original_metric_set.color_counts
  end

  def updated_color_counts
    updated_metric_set.color_counts
  end

  def final_color_counts
    final_metric_set.color_counts
  end

  def original_non_green_count
    original_metric_set.element_non_green_count
  end

  def original_percent_green
    original_metric_set.percent_green
  end

  def updated_percent_green
    updated_metric_set.percent_green
  end

  def final_precent_green
    final_metric_set.percent_green
  end

  def updated_count
    records.group(:recordable_id).count.values.sum { |record_count| record_count > 1 ? 1 : 0 }
  end

  def updated_collections_rereviewed
    records.where(state: METRIC_STATES).group(:recordable_id).count.values.sum { |record_count| record_count > 1 ? 1 : 0 }
  end

  private

  # Provides earliest revision record for each Collection/Granule
  def original_revisions
    records.where(state: METRIC_STATES).select('DISTINCT ON ("recordable_id") *').order(:recordable_id, revision_id: :asc).to_a
  end

  # Provides latest revision record for each Collection/Granule that is
  # still in the process of being reviewed
  def latest_in_progress_revisions
    records.where(state: IN_PROGRESS_METRICS).select('DISTINCT ON ("recordable_id") *').order(:recordable_id, revision_id: :desc).to_a
  end

  # Provides final revision record for Collection/Granule
  def final_revisions
    records.where(state: FINISHED_METRICS).select('DISTINCT ON ("recordable_id") *').order(:recordable_id, revision_id: :desc).to_a
  end

  def records
    @records ||= Record.where(recordable: recordables)
  end
end
