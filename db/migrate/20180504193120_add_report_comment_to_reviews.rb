class AddReportCommentToReviews < ActiveRecord::Migration[4.2]
  def change
    add_column :reviews, :report_comment, :string, default: ""
    rename_column :reviews, :comment, :review_comment
  end
end
