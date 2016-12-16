class CreateGranuleFlags < ActiveRecord::Migration
  def up
    create_table   :granule_flags do |t|
      t.belongs_to :granule_record, index: true
      t.belongs_to :user, index: true
      t.integer    :total_flag_count
      t.string     :rawJSON
    end
  end

  def down
    drop_table   :granule_flags
  end
end
