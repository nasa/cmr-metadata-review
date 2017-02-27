class CreateRecordData < ActiveRecord::Migration
  def change
    create_table :record_data do |t|
      t.references :datable, polymorphic: true, index: true
      t.string   :rawJSON
    end
  end
end
