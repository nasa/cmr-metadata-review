class CreateDiscussions < ActiveRecord::Migration
  def change
    create_table :discussions do |t|
      t.belongs_to :record, index: true, null: false
      t.belongs_to :user, index: true, null: false
      t.datetime   :date, null: false
      t.string     :column_name, null: false
      t.string     :comment
    end
  end
end