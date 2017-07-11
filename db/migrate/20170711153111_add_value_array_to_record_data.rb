class AddValueArrayToRecordData < ActiveRecord::Migration
  def change
    add_column :record_data, :value_array, :string, array: true, default: []
  end
end
