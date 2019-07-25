class AddAssociatedGranuleValueToRecords < ActiveRecord::Migration
  def change
    add_column :records, :associated_granule_value, :string
  end
end
