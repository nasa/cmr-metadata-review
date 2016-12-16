class CreateCollectionReviews < ActiveRecord::Migration
  def up
    create_table   :collection_reviews do |t|
      t.belongs_to :collection_record, index: true
      t.belongs_to :user, index: true
      t.datetime   :review_completion_date
      t.integer    :review_state
    end
  end

  def down
    drop_table   :collection_reviews
  end
end
