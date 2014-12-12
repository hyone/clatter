class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:login]

  # virtual field for screen_name or email
  attr_accessor :login

  validates :screen_name,
    presence: true,
    length: { maximum: 32 },
    uniqueness: { case_sensitive: false }

  validates :description,
    length: { maximum: 160 }

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
