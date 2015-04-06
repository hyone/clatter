class User
  module Authenticatable
    extend ActiveSupport::Concern

    included do
      # virtual field for screen_name or email
      attr_accessor :login

      has_many :authentications, dependent: :destroy
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

    class_methods do
      def find_first_by_auth_conditions(warden_conditions)
        conditions = warden_conditions.dup.to_h
        login = conditions.delete(:login)
        if login
          where(conditions).where([
            'lower(screen_name) = :value OR lower(email) = :value',
            { value: login.downcase }
          ]).first
        else
          where(conditions).first
        end
      end
    end
  end
end
