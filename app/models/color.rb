# An ActiveRecord class used to store the color codings of review data

class Color < ActiveRecord::Base
  include Datable
  
  belongs_to :record
  has_one :record_data, :as => :datable

  def update_partial_values(partial_hash)
    super(partial_hash)
    update_color_counts(self.values)
  end

  def update_color_counts(values_hash)
    counts = {"blue" => 0, "green" => 0, "red" => 0, "yellow" => 0, "" => 0}
    values_hash.each do |key, value|
      counts[value] = counts[value] + 1
    end

    self.blue_count = counts["blue"]
    self.green_count = counts["green"]
    self.yellow_count = counts["yellow"]
    self.red_count = counts["red"]
    self.save
  end

  def total_reviewed
    return self.blue_count + self.green_count + self.yellow_count + self.red_count
  end
end