class CreateCmrSyncs < ActiveRecord::Migration[5.2]
  def change
    create_table :cmr_syncs do |t|
      t.datetime :updated_since

      t.timestamps
    end
  end
end
