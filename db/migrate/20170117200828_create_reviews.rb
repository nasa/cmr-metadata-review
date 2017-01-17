class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.references :reviewable, polymorphic: true, index: true
      t.belongs_to :user, index: true
      t.datetime   :review_completion_date
      t.integer    :review_state
    end
  end
end
