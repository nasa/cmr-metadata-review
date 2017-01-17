class Granule < ActiveRecord::Base
  has_many :records, :as => :recordable
  belongs_to :collection
end