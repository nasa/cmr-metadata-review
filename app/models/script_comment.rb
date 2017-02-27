class ScriptComment < ActiveRecord::Base
  include Datable
  
  belongs_to :record
  belongs_to :user
  has_one :record_data, :as => :datable
end