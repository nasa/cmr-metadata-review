class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :ingests
  has_many :comments
  has_many :reviews 
  has_many :discussions   

  # ====Params   
  # None
  # ====Returns
  # Array of Records
  # ==== Method
  # Iterates through all collection records and returns an Array  
  # containing only the records for which the user has not attached a completed review. 
  def records_not_reviewed
    Collection.all_records.select do |record| 
      (record.reviews.select do |review| 
        (review.user == self && review.review_state == 1)
      end).empty? 
    end
  end

end
