# An ActiveRecord class used to store the color codings of review data

class Color < ActiveRecord::Base
  include Datable
  
  belongs_to :record
  has_one :record_data, :as => :datable
end