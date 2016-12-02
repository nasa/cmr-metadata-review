class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include DeviseTokenAuth::Concerns::User

  field :email, type: String
  field :encrypted_password, type: String, default: ''

  ## Recoverable
  field :reset_password_token, type: String
  field :reset_password_sent_at, type: DateTime

  ## Rememberable
  field :remember_created_at, type: DateTime

  ## Trackable
  field :sign_in_count, type: Integer, default: 0
  field :current_sign_in_at, type: DateTime
  field :last_sign_in_at, type: DateTime
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip, type: String

  ## Confirmable
  field :confirmation_token, type: String
  field :confirmed_at, type: DateTime
  field :confirmation_sent_at, type: DateTime
  field :unconfirmed_email, type: String

  ## User Info
  field :name, type: String
  field :nickname, type: String
  field :image, type: String

  ## unique oauth id
  field :provider, type: String
  field :uid, default: ''

  ## Tokens
  field :tokens, type: Hash, default: {}

  ## Index
  index({ email: 1, uid: 1, reset_password_token: 1 }, { unique: true })

  has_many :review_details
  ## Validation
  validates_uniqueness_of :email, :uid
end