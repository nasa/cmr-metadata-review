class RemoveAdminAndCuratorFromUsers < ActiveRecord::Migration[4.2]
  
  class User < ActiveRecord::Base
  end

  def up
    remove_column :users, :admin
    remove_column :users, :curator
  end

  def down
    add_column :users, :admin, :boolean, default: false
    add_column :users, :curator, :boolean, default: false

    User.all.each do |u|
      u.update_attributes({admin: u.role.eql?("admin"), curator: u.role.eql?("curator")})
    end
  end

end
