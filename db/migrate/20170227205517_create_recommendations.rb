class CreateRecommendations < ActiveRecord::Migration
  def change
    create_table :recommendations do |t|
      t.belongs_to :record, index: true
      t.integer    :total_flag_count
    end
  end
end
