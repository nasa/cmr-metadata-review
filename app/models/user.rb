class User < ApplicationRecord
  devise :timeoutable, :omniauthable, omniauth_providers: [:urs, :developer]

  has_many :ingests
  has_many :comments
  has_many :reviews
  has_many :discussions

  validates_presence_of :daac, if: Proc.new { |u| u.role.eql?("daac_curator") }

  ROLES = %w[admin arc_curator mdq_curator daac_curator].freeze

  def self.from_omniauth(auth)
    user = User.where(provider: auth.provider, uid: auth.uid).first

    unless user
      user = User.where(email: auth.info.email_address).first
      user ||= User.new
    end
    user.uid = auth.uid
    user.provider = auth.provider # this is omniauth provider type, i.e., value=URS
    user.access_token = auth.credentials['access_token']
    user.refresh_token = auth.credentials['refresh_token']
    user.email = auth.info.email_address

    if (auth.provider == 'developer')
      role = 'admin'
      daac = nil
      user.name = auth.info.name
    else
      role, daac = Cmr.get_role_and_daac(auth.uid, auth.credentials['access_token'])
      user.name = "#{auth.info['first_name']} #{auth.info['last_name']}"
      user.name = user.name.strip
    end
    user.role = role
    user.daac = ApplicationHelper.virtual_daac(daac) if daac
    user.save!
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

  def active_for_authentication?
    if Rails.env.development?
      true
    else
      super && check_if_account_active
    end
  end

  def check_if_account_active
    status, json = Cmr.get_user_info(self)

    if status != 200
      error = json['error']
      if error && error == 'invalid_token'
        access_token, refresh_token = Cmr.refresh_access_token(self)
        self.access_token = access_token
        self.refresh_token = refresh_token
        self.save!
        status, _json = Cmr.get_user_info(self)
      end
    end
    return status == 200
  end

  def inactive_message
    "Sorry, this account has been deactivated."
  end

  # ====Params
  # None
  # ====Returns
  # Array of Records
  # ==== Method
  # Iterates through all collection records and returns an Array
  # containing only the records for which the user has not attached a completed review.
  def records_not_reviewed
    application_mode = self.mdq_user? ? :mdq_mode : :arc_mode
    Collection.all_records(application_mode).select do |record|
      (record.reviews.select do |review|
        (review.user == self && review.review_state == 1)
      end).empty?
    end
  end

  def admin?
    role == 'admin'
  end

  def arc_curator?
    role == 'arc_curator'
  end

  def mdq_curator?
    role == 'mdq_curator'
  end

  def mdq_user?
    if role == 'mdq_curator'
      true
    else
      if daac.nil?
        false
      else
        ApplicationHelper::MDQ_PROVIDERS.include? daac ? true : false
      end
    end
  end

  def daac_curator?
    role == 'daac_curator'
  end

  def arc?
    admin? || arc_curator?
  end

  def save_email_preference(selection)
    if selection == 'never'
      self.email_preference = nil
    elsif %w[daily weekly biweekly monthly].include?(selection)
      self.email_preference = selection
    else
      return false
    end
    save
  end
end
