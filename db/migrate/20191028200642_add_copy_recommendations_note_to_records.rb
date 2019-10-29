class AddCopyRecommendationsNoteToRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :records, :copy_recommendations_note, :string
  end
end
