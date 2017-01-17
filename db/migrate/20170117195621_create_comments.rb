class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :commentable, polymorphic: true, index: true
      t.belongs_to :user, index: true
      t.integer    :total_comment_count
      t.string     :rawJSON
    end
  end
end
