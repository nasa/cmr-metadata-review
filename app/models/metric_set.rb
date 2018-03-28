# Metric Set Class
#
# The metric set class serves as an object that can generate predefined metric functions on an arbitrary set of records
# A MetricSet object is instantiated by providing an array of records as a parameter.
# Then all metrics are generated based on the given record set.
#
# A MetricSet containing the original revision of all records can also be instantiated from an existing MetricSet
# So a MetricSet with all revision "2" records will output a new MetricSet with all revision "1" records from the "original_record_set_function"


class MetricSet
  attr_accessor :record_set, :record_data_set

  COLORS = ["red", "blue", "green", "yellow"]

  def initialize(record_set = [])
    @record_set      = record_set
    @record_data_set = RecordData.where(record: @record_set)
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
  # This method iterates through all the record data objects of the metric set's records
  # It then created a new hash where each column name is a key and a hash of non green flag counts is the value.
  # With this hash you can call any column name and it returns a hash of the counts of each non green flag
  #
  # The method then iterates through the hash creating set objects of [column_name, all non green counts summed]
  # The purpose of this list is to tie the total non green count for all record data to each column name.
  #
  # Finally the method sorts all of the [column_name, counts] sets to find the column_names with the most non green flags.
  # This sorted list is returned so the user can grab the top n many column_names sorted by non green flag count

  def element_non_green_count
    element_hash = {}
    #creating a hash with keys of each column_name
    @record_data_set.each do |record_data|
      if !element_hash.key? record_data.column_name
        element_hash[record_data.column_name] = {"green" => 0, "red" => 0, "blue" => 0, "yellow" => 0}
      end
      if element_hash[record_data.column_name].key? record_data.color
        element_hash[record_data.column_name][record_data.color] = element_hash[record_data.column_name][record_data.color] + 1
      end
    end

    #tuning hash into list of [column_name, non_green_count, green_count] sets
    column_counts = []
    element_hash.map do |column_name, counts_hash|
      column_counts.push([column_name, (counts_hash.values.sum - counts_hash["green"]), counts_hash["green"]])
    end

    #sorting in reverse order so highest counts are first
    column_counts.sort! { |x,y| y[1] <=> x[1] }
  end

  private

  def get_color_counts
    colors_zero_arrays = COLORS.collect { |c| [c, 0] }
    default_colors = Hash[colors_zero_arrays]

    counts = @record_data_set.where(color: COLORS).group(:color).count

    default_colors.merge(counts)
  end
end
