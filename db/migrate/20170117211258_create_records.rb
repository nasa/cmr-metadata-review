class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.references :recordable, polymorphic: true, index: true
      t.string    :revision_id
      t.boolean  :closed
    end
  end
end
