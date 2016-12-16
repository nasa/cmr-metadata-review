class CreateGranuleReviews < ActiveRecord::Migration
  def up
    create_table   :granule_reviews do |t|
      t.belongs_to :granule_record, index: true
      t.belongs_to :user, index: true
      t.datetime   :review_completion_date
      t.integer    :review_state
    end
  end

  def down
    drop_table   :granule_reviews
  end
end
