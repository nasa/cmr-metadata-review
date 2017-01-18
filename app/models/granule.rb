class Granule < ActiveRecord::Base
  has_many :records, :as => :recordable
  belongs_to :collection

  def self.create_related_granules
    
  end
end