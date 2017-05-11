class AddFormatTypeToRecords < ActiveRecord::Migration
  def change
    add_column :records, :format, :string, default: ""
  end
end
