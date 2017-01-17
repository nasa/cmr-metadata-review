class Review < ApplicationRecord
  belongs_to :reviewable, polymorphic: true
end