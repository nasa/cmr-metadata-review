class AddReleasedToDaacDateToRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :records, :released_to_daac_date, :datetime
    time = Time.zone.now
    Record.where(state: :in_daac_review).each do |record|
      record.update_column('released_to_daac_date', time) if record.released_to_daac_date.blank?
    end
  end
end
