class RecordsUpdateLock < ActiveRecord::Base

  def get_last_update
    if !self.last_update
      self.last_update = DateTime.now
      self.save
    end
    return self.last_update
  end


  # ====Params   
  # None
  # ====Returns
  # String 
  # ==== Method
  # Takes the raw UTC last_update attribute and returns a string version     
  # of the dateTime in EST Timezone, "03/09/2017 at 4:15pm"
  def self.formatted_last_update
    last_update = (RecordsUpdateLock.find_by id: 1)
    if last_update.nil?
      "Has not been updated"
    else
      last_update.get_last_update.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d/%Y at %I:%M%p") + " ET"
    end
  end

end