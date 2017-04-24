class RecordsUpdateLock < ActiveRecord::Base

  def get_last_update
    if !self.last_update
      self.last_update = DateTime.now
      self.save
    end
    return self.last_update
  end

  def self.formatted_last_update
    last_update = (RecordsUpdateLock.find_by id: 1).get_last_update
    return last_update.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d/%Y at %I:%M%p")
  end

end