class AddDaacToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :daac, :string, default: nil
  end
end
