class CreateIngests < ActiveRecord::Migration
  def change
    create_table :ingests do |t|
      t.belongs_to :record, index: true
      t.belongs_to :user, index: true
      t.datetime   :date_ingested
    end
  end
end
