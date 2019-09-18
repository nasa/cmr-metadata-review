class AddAssociatedGranuleValueToRecords < ActiveRecord::Migration[4.2]
  def change
    add_column :records, :associated_granule_value, :string
  end
end
