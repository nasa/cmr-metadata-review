class AddColumnNameIndexToRecordData < ActiveRecord::Migration
  def change
    add_index :record_data, :column_name
  end
end
