class AddNativeFormatToRecord < ActiveRecord::Migration[5.2]
  def up
    add_column :records, :native_format, :string
    Record.all.each do |record|
      record.native_format = record.format
      record.save
    end
  end

  def down
    remove_column :records, :native_format
  end
end
