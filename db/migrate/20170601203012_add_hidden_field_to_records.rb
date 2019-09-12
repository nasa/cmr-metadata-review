class AddHiddenFieldToRecords < ActiveRecord::Migration[4.2]
  def change
    add_column :records, :hidden, :boolean, default: false
  end
end
