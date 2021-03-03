class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.to_csv
    csv_string = CSV.generate do |csv|
      csv << column_names
      all.find_each do |model|
        csv << model.attributes.values_at(*column_names)
      end
    end
    csv_string
  end
end
