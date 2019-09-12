class AddRoleToUsers < ActiveRecord::Migration[4.2]

  class User < ActiveRecord::Base
  end

  def change
    add_column :users, :role, :string
    User.all.each do |u|
      u.update_attribute(:role, u.admin ? "admin" : u.curator ? "arc_curator" : nil)
    end
  end
end