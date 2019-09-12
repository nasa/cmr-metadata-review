class AddColumnNameIndexToRecordData < ActiveRecord::Migration[4.2]
  def change
    add_index :record_data, :column_name
  end
end
