class Flag < ApplicationRecord
  belongs_to :flagable, polymorphic: true
end