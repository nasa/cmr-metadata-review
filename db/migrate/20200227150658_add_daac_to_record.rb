class AddDaacToRecord < ActiveRecord::Migration[5.2]
  include RecordHelper
  def up
    add_column :records, :daac, :string
    Record.all.each do |record|
      record.daac = daac_from_concept_id(record.concept_id)
      record.save
    end
    remove_column :record_data, :daac
  end

  def down
    add_column :record_data, :daac, :string
    Record.all.each do |record|
      record.record_datas.update_all(daac: record.daac)
    end
    remove_column :records, :daac
  end
end
