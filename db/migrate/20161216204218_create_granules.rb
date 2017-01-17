class CreateGranules < ActiveRecord::Migration
  def up
    create_table :granules do |t|
      t.string   :concept_id
      t.belongs_to :collection, index: true
    end
  end

  def down
    drop_table   :granules
  end
end
