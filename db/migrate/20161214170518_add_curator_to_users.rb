class AddCuratorToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :curator, :boolean, default: false
  end
end
