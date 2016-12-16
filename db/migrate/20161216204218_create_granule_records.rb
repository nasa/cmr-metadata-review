class CreateGranuleRecords < ActiveRecord::Migration
  def up
    create_table :granule_records do |t|
      t.string   :name
      t.float    :version_id
      t.string   :collection_concept_id
      t.boolean  :closed
      t.string   :rawJSON
    end
  end

  def down
    drop_table   :granule_records
  end
end
