class CollectionRecord < ActiveRecord::Base
  has_many :collection_flags
  has_one :collection_ingests
  has_many :collection_comments
  has_many :collection_reviews

  has_many :users, through: :collection_reviews   
end
