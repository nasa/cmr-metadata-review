class CreateScriptComments < ActiveRecord::Migration
  def change
    create_table :script_comments do |t|
      t.belongs_to :record, index: true
      t.belongs_to :user, index: true
      t.integer    :total_comment_count
    end
  end
end
