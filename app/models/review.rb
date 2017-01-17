class Review < ActiveRecord::Base
  belongs_to :record
  belongs_to :user
end