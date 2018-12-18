class AddRefreshTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :refresh_token, :string
  end
end
