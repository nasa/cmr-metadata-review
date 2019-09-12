class AddIndexToRecordData < ActiveRecord::Migration[4.2]
  def change
    add_column :record_data, :order_count, :integer, default: 0
  end
end
