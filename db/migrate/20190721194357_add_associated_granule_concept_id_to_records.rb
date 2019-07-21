class AddAssociatedGranuleConceptIdToRecords < ActiveRecord::Migration
  def change
    add_column :records, :associated_granule_concept_id, :string
  end
end
