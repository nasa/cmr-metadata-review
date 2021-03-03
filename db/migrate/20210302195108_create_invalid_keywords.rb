class CreateInvalidKeywords < ActiveRecord::Migration[5.2]
  def change
    create_table :invalid_keywords do |t|
      t.string :provider_id
      t.string :concept_id
      t.integer :revision_id
      t.string :short_name
      t.string :version
      t.string :invalid_keyword_path
      t.string :valid_keyword_path
      t.string :ummc_field

      t.timestamps
    end
  end
end
