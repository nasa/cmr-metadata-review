class AddDaacToUsers < ActiveRecord::Migration
  def change
    add_column :users, :daac, :string, default: nil
  end
end
