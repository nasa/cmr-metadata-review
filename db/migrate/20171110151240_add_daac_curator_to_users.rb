class AddDaacCuratorToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :daac_curator, :boolean, default: false
  	add_column :users, :daac, :string
  end
end
