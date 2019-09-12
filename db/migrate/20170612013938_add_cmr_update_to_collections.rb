class AddCmrUpdateToCollections < ActiveRecord::Migration[4.2]
  def change
    add_column :collections, :cmr_update, :boolean, default: true
  end
end
