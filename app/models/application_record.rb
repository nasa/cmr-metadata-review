class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.find_each do |model|
        csv << model.attributes.values_at(*column_names)
      end
    end
  end
end
