class CreateCollectionRecords < ActiveRecord::Migration
  def up
    create_table :collection_records do |t|
      t.string   :concept_id, null: false
      t.string   :short_name, default: ""
      t.float    :version_id
      t.boolean  :closed
      t.string   :rawJSON
    end
  end

  def down
    drop_table   :collection_records
  end

end
