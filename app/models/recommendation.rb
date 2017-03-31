# ActiveRecord class used to store recommendation strings for record review fields.     
# Data is stored using the RecordData model as an attribute of Recommendation.

class Recommendation < ActiveRecord::Base
  include Datable
  
  belongs_to :record
  has_one :record_data, :as => :datable
end