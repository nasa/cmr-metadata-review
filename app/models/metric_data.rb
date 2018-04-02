# Keeps track of the each metric set type for a set of recordables
class MetricData
  attr_reader :recordables

  # TODO Update this with the Record::STATE_FINISHED constant when finished work is moved in
  IN_PROGRESS_METRICS = [Record::STATE_CLOSED, Record::STATE_IN_DAAC_REVIEW]
  FINISHED_METRICS    = [:finished]
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
    records_arrays.reduce(0) do |sum, records|
      value = records.count > 1 ? 1 : 0
      sum + value
    end
  end

  def updated_collections_rereviewed
    records_arrays.reduce(0) do |sum, records|
      value = records.where(state: METRIC_STATES).count > 1 ? 1 : 0
      sum + value
    end
  end

  private

  # Provides earliest revision record for each Collection/Granule
  def original_revisions
    records_arrays.map do |records|
      records.where(state: METRIC_STATES).order("revision_id ASC").first
    end.compact
  end

  # Provides latest revision record for each Collection/Granule that is
  # still in the process of being reviewed
  def latest_in_progress_revisions
    records_arrays.map do |records|
      records.where(state: IN_PROGRESS_METRICS).order("revision_id DESC").first
    end.compact
  end

  # Provides final revision record for Collection/Granule
  def final_revisions
    records_arrays.map do |records|
      records.where(state: FINISHED_METRICS).order("revision_id DESC").first
    end.compact
  end

  # Array of arrays of all records
  def records_arrays
    @records_arrays||= recordables.map(&:records)
  end
end
