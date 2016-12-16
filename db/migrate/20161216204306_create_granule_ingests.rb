class CreateGranuleIngests < ActiveRecord::Migration
  def up
    create_table   :granule_ingests do |t|
      t.belongs_to :granule_record, index: true
      t.belongs_to :user, index: true
      t.datetime   :date_ingested
    end
  end

  def down
    drop_table   :granule_flags
  end
end
