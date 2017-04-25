class AddIndexToCollections < ActiveRecord::Migration
  def change
    add_index :collections, :concept_id
  end
end
