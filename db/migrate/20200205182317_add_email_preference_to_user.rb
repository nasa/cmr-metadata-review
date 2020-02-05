class AddEmailPreferenceToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :email_preference, :string
  end
end
