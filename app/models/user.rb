class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :ingests
  has_many :comments
  has_many :reviews
  has_many :discussions

  validates_presence_of :daac, if: Proc.new { |u| u.role.eql?("daac_curator") }

  ROLES = %w[admin arc_curator daac_curator].freeze

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

  # ====Params
  # None
  # ====Returns
  # Whether or not the User is an admin.
  # ==== Method
  # This method checks if the user is a "admin", which is a legacy role name. It's only
  # intended for backwards compatibility. For new code, use the 'role' attribute directly.
  def admin
    role.eql?("admin")
  end

  # ====Params
  # None
  # ====Returns
  # Whether or not the User is a curator.
  # ==== Method
  # This method checks if the user is a "curator", which is a legacy role name. It's only
  # intended for backwards compatibility. For new code, use the 'role' attribute directly.
  def curator
    role.eql?("arc_curator")
  end

  def daac_curator?
    role == "daac_curator"
  end

  def arc?
    admin || curator
  end
end
