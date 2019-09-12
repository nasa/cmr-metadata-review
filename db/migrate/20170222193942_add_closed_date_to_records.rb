class AddClosedDateToRecords < ActiveRecord::Migration[4.2]
  def change
    add_column :records, :closed_date, :datetime
  end
end
