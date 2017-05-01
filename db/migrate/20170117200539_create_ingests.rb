class CreateIngests < ActiveRecord::Migration
  def change
    create_table :ingests do |t|
      t.belongs_to :record, index: true, null: false
      t.belongs_to :user, index: true, null: false
      t.datetime   :date_ingested, null: false
    end
  end
end
