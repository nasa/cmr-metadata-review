class User < ActiveRecord::Base
  devise :omniauthable, :omniauth_providers => [:urs]

  has_many :ingests
  has_many :comments
  has_many :reviews
  has_many :discussions

  validates_presence_of :daac, if: Proc.new { |u| u.role.eql?("daac_curator") }

  ROLES = %w[admin arc_curator daac_curator].freeze

  def self.from_omniauth(auth)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    if !user
      user = User.new
      user.uid = auth.uid
      user.role = Cmr.getRole(auth.uid, auth.credentials["access_token"]);
      user.provider = auth.provider # this is omniauth provider type, i.e., value=URS
      user.email = auth.info.email_address
      user.save
    else
      user.role = Cmr.getRole(auth.uid, auth.credentials["access_token"]);
      user.save
    end
    user
  end

  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

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
