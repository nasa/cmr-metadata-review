# Active Record Class used to store the user and dateTime of bringing a    
# record from the CMR into this metadata dashboard DB.

class Ingest < ActiveRecord::Base
  belongs_to :record
  belongs_to :user
end