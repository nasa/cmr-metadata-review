class AddCommentToReview < ActiveRecord::Migration
  def change
    add_column :reviews, :comment, :string, default: ""
  end
end
