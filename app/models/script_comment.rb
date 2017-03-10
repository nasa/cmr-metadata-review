# ActiveRecord class used to store results of the automated script check for record review fields.     
# Data is stored using the RecordData model as an attribute of ScriptComment.

class ScriptComment < ActiveRecord::Base
  include Datable
  
  belongs_to :record
  has_one :record_data, :as => :datable
end