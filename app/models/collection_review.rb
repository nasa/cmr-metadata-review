class CollectionReview < ActiveRecord::Base
  #review_state field has value of 0 for "in process" and 1 for "complete"
  belongs_to :collection_record
  belongs_to :user
end
