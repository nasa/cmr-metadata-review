class AddFormatTypeToRecords < ActiveRecord::Migration[4.2]
  def change
    add_column :records, :format, :string, default: ""
  end
end
