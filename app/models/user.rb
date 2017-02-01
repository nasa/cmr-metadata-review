class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :flags
  has_many :ingests
  has_many :comments
  has_many :reviews   
  # has_many :collection_records, through: :collection_reviews  

  # has_many :granule_records, through: :granule_reviews    
     

  def records_not_reviewed
    Collection.all_records.select do |record| 
      (record.reviews.select do |review| 
        (review.user == self && review.review_state == 1)
      end).empty? 
    end
  end

end
