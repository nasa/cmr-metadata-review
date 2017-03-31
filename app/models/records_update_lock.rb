class RecordsUpdateLock < ActiveRecord::Base

  def get_last_update
    if !self.last_update
      self.last_update = DateTime.now
      self.save
    end
    return self.last_update
  end

end