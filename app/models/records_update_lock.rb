class RecordsUpdateLock < ActiveRecord::Base

  def self.within_lock
    begin
      update_lock_num, lock = RecordsUpdateLock.get_lock
      if update_lock_num != 0 && lock.has_lock?(update_lock_num)
        
        yield

        lock.set_last_update(update_lock_num, DateTime.now)
        lock.release_lock(update_lock_num)
      end
    rescue
      RecordsUpdateLock.reset_lock
    end
  end

  def self.get_lock
    lock_object = RecordsUpdateLock.find_or_create_by(id: 1)

    if lock_object.lock.nil? || lock_object.lock == 0
      random_num = Random.rand(10000) + 1
      lock_object.lock = random_num
      lock_object.save
      return random_num, lock_object
    else
      return 0
    end
  end

  def release_lock(lock_num)
    if self.lock == lock_num
      self.lock = 0
      self.save
      return true
    else
      return false
    end
  end

  def has_lock?(lock_num)
    if self.lock == lock_num
      return true
    else
      return false
    end    
  end

  def self.get_last_update
    lock_object = RecordsUpdateLock.find_or_create_by(id: 1)
    if lock_object.last_update.nil?
      lock_object.last_update = DateTime.now
      lock_object.save
      return lock_object.last_update
    else
      return lock_object.last_update
    end  
  end

  def set_last_update(lock_num, new_datetime)
    if self.lock == lock_num
      self.last_update = new_datetime
      self.save
      return true
    else
      return false
    end 
  end

  def self.reset_lock
    lock_object = RecordsUpdateLock.find_or_create_by(id: 1)
    lock_object.lock = 0
    lock_object.save
  end

end