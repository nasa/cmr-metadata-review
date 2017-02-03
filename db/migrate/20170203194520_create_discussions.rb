class CreateDiscussions < ActiveRecord::Migration
  def change
    create_table :discussions do |t|
      t.belongs_to :record, index: true
      t.belongs_to :user, index: true
      t.datetime   :date
      t.string     :column_name
      t.string     :comment
    end
  end
end