class RemoveUnreviewedRecordsFromGesDiscAndAsf < ActiveRecord::Migration[5.2]
  def change
    records_to_update_daac = Record.where(daac: nil)

    records_to_update_daac.each do |record|
      record.update(daac: record.recordable.concept_id.split('-').second)
    end

    Record.open.where(daac: 'GES_DISC').destroy_all
    Record.open.where(daac: 'ASF').destroy_all
  end
end
