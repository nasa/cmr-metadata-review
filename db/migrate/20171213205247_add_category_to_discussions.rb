class AddCategoryToDiscussions < ActiveRecord::Migration
  def change
    add_column :discussions, :category, :integer, default: 0
  end
end
