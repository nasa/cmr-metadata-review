class Recommendation < ActiveRecord::Base
  include Datable
  
  belongs_to :record
  has_one :record_data, :as => :datable
end