class CreateRecordData < ActiveRecord::Migration
  def change
    create_table :record_data do |t|
      t.belongs_to :record, index: true, null: false
      t.string     :value, default: ""
      t.string     :daac
      t.datetime   :last_updated
      t.string     :column_name, null: false
      t.string     :color, default: ""
      t.string     :script_comment, default: ""
      t.boolean    :opinion, default: false
      t.string     :flag, array: true, default: []
      t.string     :recommendation, default: ""
    end
  end
end
