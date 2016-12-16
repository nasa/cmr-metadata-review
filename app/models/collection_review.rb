class CollectionReview < ActiveRecord::Base
  belongs_to :collection_record
  belongs_to :user
end
