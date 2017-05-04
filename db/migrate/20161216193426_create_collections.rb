class CreateCollections < ActiveRecord::Migration
  def up
    create_table :collections do |t|
      t.string   :concept_id, null: false, index: true
      t.string   :short_name, default: ""
    end
  end

  def down
    drop_table   :collections
  end

end
