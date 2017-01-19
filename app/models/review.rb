class Review < ActiveRecord::Base
  belongs_to :record
  belongs_to :user

  def state_string
    if self.review_state == 0
      "In Process"
    else
      "Completed"
    end
  end

  def formatted_date
    #01/19/2017 at 01:55PM (example format)
    if self.review_completion_date.nil?
      return ""
    else
      return self.review_completion_date.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d/%Y at %I:%M%p")
    end
  end

end