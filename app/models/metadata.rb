class Metadata < ApplicationRecord
  self.abstract_class = true

  def get_records(descending = true)
    visible_records = records.visible
    sorted_records = visible_records.sort_by { |record| record.revision_id.to_i }
    sorted_records.reverse! if descending
    sorted_records
  end

end