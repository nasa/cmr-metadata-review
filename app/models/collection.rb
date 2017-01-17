class Collection < ActiveRecord::Base
  has_many :records, :as => :recordable
  has_many :granules
end