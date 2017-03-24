class AddCountsToColor < ActiveRecord::Migration
  def change
    add_column :colors, :blue_count, :integer, :default => 0
    add_column :colors, :red_count, :integer, :default => 0
    add_column :colors, :yellow_count, :integer, :default => 0
    add_column :colors, :green_count, :integer, :default => 0
  end
end
