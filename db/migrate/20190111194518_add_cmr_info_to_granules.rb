class AddCmrInfoToGranules < ActiveRecord::Migration[4.2]
  def change
    add_column :granules, :latest_revision_in_cmr, :string
    add_column :granules, :deleted_in_cmr, :boolean
  end
end
