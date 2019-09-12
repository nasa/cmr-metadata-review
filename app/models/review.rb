class Review < ApplicationRecord
  belongs_to :record
  belongs_to :user

  before_save :set_completion_date

  # ====Params   
  # None
  # ====Returns
  # Boolean
  # ==== Method
  # Checks the review and returns true if the review state is set as complete and there is a non nil completion date value.
  def completed?
    return (self.review_state == 1 && !self.review_completion_date.nil?)
  end

  # ====Params   
  # None
  # ====Returns
  # Void
  # ==== Method
  # Updates the review state to complete and adds a completion dateTime of Now to the review.     
  # Also saves the updated review in the DB
  def mark_complete
    self.review_state = 1
    self.review_completion_date = DateTime.now
    self.save
  end


  # ====Params   
  # None
  # ====Returns
  # String
  # ==== Method
  # Helper to return the state of a review in String form     
  # Returns "In Process" or "Completed"
  def state_string
    if self.review_state == 0
      "In Process"
    else
      "Completed"
    end
  end


  # ====Params   
  # None
  # ====Returns
  # String 
  # ==== Method
  # Takes the raw UTC dateTime attribute and returns a string version     
  # of the dateTime in EST Timezone, "03/09/2017 at 4:15pm"
  def formatted_date
    #01/19/2017 at 01:55PM (example format)
    if self.review_completion_date.nil?
      return ""
    else
      return self.review_completion_date.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d/%Y at %I:%M%p")
    end
  end

  # ====Params   
  # None
  # ====Returns
  # Review Array
  # ==== Method
  # Returns all reviews that are associated with non hidden records
  def self.get_reviews
    Review.all.select do |review|
      record = review.record
      (!record.nil?) && (!record.hidden?) 
    end
  end

  def reviewer_email
    self.user.email
  end

  private

  def set_completion_date
    self.review_completion_date = DateTime.now
  end

end