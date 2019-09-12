class AddCommentToReview < ActiveRecord::Migration[4.2]
  def change
    add_column :reviews, :comment, :string, default: ""
  end
end
