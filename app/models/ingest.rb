class Ingest < ApplicationRecord
  belongs_to :ingestable, polymorphic: true
end