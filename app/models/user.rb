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

    unless user
      user = User.new
      user.uid = auth.uid
      user.provider = auth.provider # this is omniauth provider type, i.e., value=URS
    end
    user.access_token = auth.credentials["access_token"]
    user.refresh_token = auth.credentials["refresh_token"]
    user.email = auth.info.email_address

    role, daac = Cmr.get_role_and_daac(auth.uid, auth.credentials["access_token"])
    user.role = role
    user.daac = daac if daac
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
    super && check_if_account_active
  end

  def check_if_account_active
    response = get_user_info
    if response.status != 200
      error = JSON.parse(response.body)['error']
      if error && error == 'invalid_token'
        refresh_access_token
        response = get_user_info
      end
    end
    response.status == 200
  end

  def inactive_message
    "Sorry, this account has been deactivated."
  end

  def refresh_access_token
    conn = Faraday.new(:url => "#{ENV['urs_site']}") do |faraday|
      faraday.request :url_encoded # form-encode POST params
      faraday.headers['Authorization'] = 'Basic ' + ["#{ENV['urs_client_id']}:#{ENV['urs_client_secret']}"].pack('m0')
      faraday.response :logger # log requests to $stdout
      faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
    end
    response = conn.post "/oauth/token",
                         # calling_interface: ENV['urs_client_id'],
                         grant_type: "refresh_token",
                         refresh_token: refresh_token

    json = JSON.parse(response.body)

    self.access_token = json["access_token"]
    self.refresh_token = json["refresh_token"]
    save!
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

  private

  def get_user_info
    conn = Faraday.new(:url => "#{ENV['urs_site']}") do |faraday|
      faraday.request :url_encoded # form-encode POST params
      faraday.headers['Authorization'] = "Bearer #{access_token}"
      faraday.response :logger # log requests to $stdout
      faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
    end
    response = conn.get "/api/users/#{uid}?calling_application=#{ENV['urs_client_id']}"
    return response
  end
end
