class AddDaacToRecord < ActiveRecord::Migration[5.2]
  def change
    add_column :records, :daac, :string
    Record.all.each do |record|
      record.daac = record.record_datas.first.daac
      record.save
    end
    remove_column :record_data, :daac
  end
end
