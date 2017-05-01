class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.belongs_to :record, index: true, null: false
      t.belongs_to :user, index: true, null: false
      t.datetime   :review_completion_date
      t.integer    :review_state, null: false
    end
  end
end
