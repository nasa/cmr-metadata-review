class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.belongs_to :record, index: true
      t.belongs_to :user, index: true
      t.integer    :total_comment_count
      t.string     :rawJSON
    end
  end
end
