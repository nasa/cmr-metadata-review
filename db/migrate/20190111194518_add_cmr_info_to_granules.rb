class AddCmrInfoToGranules < ActiveRecord::Migration
  def change
    add_column :granules, :latest_revision_in_cmr, :string
    add_column :granules, :deleted_in_cmr, :boolean
  end
end
