class CreateCollectionComments < ActiveRecord::Migration
  def up
    create_table   :collection_comments do |t|
      t.belongs_to :collection_record, index: true
      t.belongs_to :user, index: true
      t.integer    :total_comment_count
      t.string     :rawJSON
    end
  end

  def down
    drop_table   :collection_comments
  end
end
