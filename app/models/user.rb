class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:github, :google_oauth2, :twitter],
         :authentication_keys => [:login]

  has_many :authentications, dependent: :destroy
  has_many :messages, dependent: :destroy

  has_many :relationships, foreign_key: 'follower_id',
                           dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed

  has_many :reverse_relationships, foreign_key: 'followed_id',
                                   dependent: :destroy,
                                   class_name: 'Relationship'
  has_many :followers, through: :reverse_relationships, source: :follower

  # virtual field for screen_name or email
  attr_accessor :login

  mount_uploader :profile_image, ProfileImageUploader

  validates :screen_name,
    presence: true,
    length: { maximum: 32 },
    uniqueness: { case_sensitive: false }

  validates :name,
    presence: true

  validates :description,
    length: { maximum: 160 }


  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy
  end


  def apply_omniauth(omniauth)
    self.name  = omniauth['info']['name']  if name.blank?
    self.email = omniauth['info']['email'] if email.blank?

    authentications.build(
      provider: omniauth['provider'],
      uid: omniauth['uid'],
      account_name: omniauth['info']['_account_name'],
      url: omniauth['info']['_url']
    )
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end

  class << self
    def find_first_by_auth_conditions(warden_conditions)
      conditions = warden_conditions.dup
      if login = conditions.delete(:login)
        where(conditions).where(["lower(screen_name) = :value OR lower(email) = :value", {
          value: login.downcase
        }]).first
      else
        where(conditions).first
      end
    end
  end

end
