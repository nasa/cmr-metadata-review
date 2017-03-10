# ActiveRecord class used to store lists of flags related to a record review.     
# Data is stored using the RecordData model as an attribute of Flag.

class Flag < ActiveRecord::Base
  include Datable
  
  belongs_to :record
  has_one :record_data, :as => :datable
end