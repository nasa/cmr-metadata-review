class Discussion < ActiveRecord::Base
  belongs_to :record
  belongs_to :user

  def formatted_date
    #01/19/2017 at 01:55PM (example format)
    if self.date.nil?
      return ""
    else
      return self.date.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d/%Y at %I:%M%p")
    end
  end
end