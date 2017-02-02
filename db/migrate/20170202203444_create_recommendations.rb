class CreateRecommendations < ActiveRecord::Migration
  def change
    create_table :recommendations do |t|
      t.belongs_to :record, index: true
      t.belongs_to :user, index: true
      t.string     :row_name
      t.integer    :record_info_count
      t.string     :rawJSON
      t.string     :usersRawJSON
    end
  end
end