class CreateRecordRows < ActiveRecord::Migration
  def change
    create_table :record_rows do |t|
      t.belongs_to :record, index: true
      t.belongs_to :user, index: true
      t.string     :row_name
      t.integer    :record_info_count
      t.string     :rawJSON
    end
  end
end