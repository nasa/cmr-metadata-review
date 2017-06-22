class AddCmrUpdateToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :cmr_update, :boolean, default: true
  end
end
