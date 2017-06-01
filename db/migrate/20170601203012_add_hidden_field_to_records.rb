class AddHiddenFieldToRecords < ActiveRecord::Migration
  def change
    add_column :records, :hidden, :boolean, default: false
  end
end
