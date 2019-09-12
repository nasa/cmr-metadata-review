class CreateGranules < ActiveRecord::Migration[4.2]
  def up
    create_table :granules do |t|
      t.string   :concept_id, null: false
      t.belongs_to :collection, index: true
    end
  end

  def down
    drop_table   :granules
  end
end
