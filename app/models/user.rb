class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :collection_flags
  has_many :collection_ingests
  has_many :collection_comments
  has_many :collection_reviews   
  has_many :collection_records, through :collection_reviews   
     
end
