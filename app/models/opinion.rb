# ActiveRecord class used to store second_opinion requests for record review fields.     
# Data is stored using the RecordData model as an attribute of Opinion.

class Opinion < ActiveRecord::Base
  include Datable
  
  belongs_to :record
  has_one :record_data, :as => :datable
end