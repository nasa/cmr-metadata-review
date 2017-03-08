class CreateOpinions < ActiveRecord::Migration
  def change
    create_table :opinions do |t|
      t.belongs_to :record, index: true
      t.integer    :total_flag_count
    end
  end
end
