class CreateCollectionIngests < ActiveRecord::Migration
  def up
    create_table   :collection_ingests do |t|
      t.belongs_to :collection_record, index: true
      t.belongs_to :user, index: true
      t.datetime   :date_ingested
    end
  end

  def down
    drop_table   :collection_flags
  end
end
