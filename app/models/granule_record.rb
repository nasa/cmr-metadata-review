class GranuleRecord < ActiveRecord::Base
  has_many :granule_flags
  has_many :granule_ingests
  has_many :granule_comments
  has_many :granule_reviews

  has_many :users, through: :granule_reviews 
end
