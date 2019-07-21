class AddAssociatedGranuleRevisionIdToRecords < ActiveRecord::Migration
  def change
    add_column :records, :associated_granule_revision_id, :string
  end
end
