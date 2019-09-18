class CreateCollections < ActiveRecord::Migration[4.2]
  def up
    create_table :collections do |t|
      t.string   :concept_id, null: false
      t.string   :short_name, default: ""
    end
  end

  def down
    drop_table   :collections
  end

end
