class CreateIngests < ActiveRecord::Migration
  def change
    create_table :ingests do |t|
      t.references :ingestable, polymorphic: true, index: true
      t.belongs_to :user, index: true
      t.datetime   :date_ingested
    end
  end
end
