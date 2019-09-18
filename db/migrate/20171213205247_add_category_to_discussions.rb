class AddCategoryToDiscussions < ActiveRecord::Migration[4.2]
  def change
    add_column :discussions, :category, :integer, default: 0
  end
end
