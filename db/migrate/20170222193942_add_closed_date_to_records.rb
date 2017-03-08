class AddClosedDateToRecords < ActiveRecord::Migration
  def change
    add_column :records, :closed_date, :datetime
  end
end
