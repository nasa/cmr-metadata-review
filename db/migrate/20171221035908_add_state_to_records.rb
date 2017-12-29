class AddStateToRecords < ActiveRecord::Migration
  def change
    add_column :records, :state, :string
  end
end
