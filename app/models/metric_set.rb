# Metric Set Class
#
# The metric set class serves as an object that can generate predefined metric functions on an arbitrary set of records
# A MetricSet object is instantiated by providing an array of records as a parameter.
# Then all metrics are generated based on the given record set.
#
# A MetricSet containing the original revision of all records can also be instantiated from an existing MetricSet
# So a MetricSet with all revision "2" records will output a new MetricSet with all revision "1" records from the "original_record_set_function"


class MetricSet
  attr_accessor :record_data_set

  COLORS           = ["red", "blue", "green", "yellow"]
  NON_GREEN_COLORS = ["red", "blue", "yellow"]

  def initialize(record_set = [])
    @record_data_set = RecordData.where(record: record_set)
  end

  # ====Params
  # None
  # ====Returns
  # Hash {color_string => count}
  # ==== Method
  # Then aggregates the counts of each flag type in record_data_set and returns a hash of those values

  def color_counts
    @color_counts ||= get_color_counts
  end

  def percent_green
   color_counts["green"].to_f / color_counts.values.sum.to_f * 100
  end

  # ====Params
  # None
  # ====Returns
  # Array of [column_name, non_green_count] sets.  Double depth array
  # ==== Method
  # This method queries the DB for the ten elements with the most errors

  def element_non_green_count
    @record_data_set.where(color: NON_GREEN_COLORS).group(:column_name).order('count_all DESC').limit(10).count.to_a
  end

  private

  def get_color_counts
    colors_zero_arrays = COLORS.collect { |c| [c, 0] }
    default_colors = Hash[colors_zero_arrays]

    counts = @record_data_set.where(color: COLORS).group(:color).count

    default_colors.merge(counts)
  end
end
