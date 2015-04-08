# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  screen_name            :string           not null
#  name                   :string           not null
#  description            :string(160)
#  url                    :string
#  profile_image          :string
#  messages_count         :integer          default(0), not null
#  following_count        :integer          default(0), not null
#  followers_count        :integer          default(0), not null
#  favorites_count        :integer          default(0), not null
#  time_zone              :string           default("UTC")
#  lang                   :string
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_screen_name           (screen_name) UNIQUE
#

class User < ActiveRecord::Base
  before_save { screen_name.downcase! }

  extend FriendlyId
  friendly_id :screen_name

  mount_uploader :profile_image, ProfileImageUploader

  validates :screen_name, presence: true,
                          length: { maximum: 15 },
                          format: { with: /\A[[:alpha:]_][[:alnum:]_]*\Z/ },
                          uniqueness: { case_sensitive: false }
  # For multiple format validations
  validates :screen_name, format: { without: /\A[[:digit:]_]+\Z/ }

  validates :name, presence: true

  validates :description, length: { maximum: 160 }

  scope :newer, lambda {
    order(created_at: :desc)
  }

  # XXX: if 'devise' declaration is defined in 'included' block in User::Authenticatable,
  #      raise 'PG::UndefinedColumn: ERROR: column users.login does not exist'
  #      so, we should defined it here...
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable,
         omniauth_providers: Devise.omniauth_providers,
         authentication_keys: [:login]

  include User::Authenticatable
  include User::MessageOwnable
  include User::Followable
  include User::Favoritable
  include User::Retweetable
  include User::Searchable
end
