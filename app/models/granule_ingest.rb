class GranuleIngest < ActiveRecord::Base
  belongs_to :granule_record
  belongs_to :user
end
