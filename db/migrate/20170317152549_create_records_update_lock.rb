class CreateRecordsUpdateLock < ActiveRecord::Migration[4.2]
  def change
    create_table :records_update_locks do |t|
      t.datetime   :last_update, null: false
    end
  end
end
