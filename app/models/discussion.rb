# An ActiveRecord class that keeps all discussion strings related to a record review.     
# Discussion objects are stored with record, user, fieldName, and dateTime attributes   
# The discussion strings are then attached to each fieldName shown on a review screen and sorted by dateTime.

class Discussion < ActiveRecord::Base
  belongs_to :record
  belongs_to :user


  # ====Params   
  # None
  # ====Returns
  # String 
  # ==== Method
  # Takes the raw UTC dateTime attribute and returns a string version     
  # of the dateTime in EST Timezone, "03/09/2017 at 4:15pm"
  def formatted_date
    #01/19/2017 at 01:55PM (example format)
    if self.date.nil?
      return ""
    else
      return self.date.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d/%Y at %I:%M%p")
    end
  end
end