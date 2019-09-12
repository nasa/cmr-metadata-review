class CreateRecords < ActiveRecord::Migration[4.2]
  def change
    create_table :records do |t|
      t.references :recordable, polymorphic: true, index: true, null: false
      t.string    :revision_id, null: false
      t.boolean  :closed, default: false
    end
  end
end
