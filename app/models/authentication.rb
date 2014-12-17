class Authentication < ActiveRecord::Base
  belongs_to :user

  validates :provider, presence: true
  validates :uid, presence: true
  validates :user, presence: true
  validates :account_name, presence: true

  # be able to delete the authentication,
  # only when its user has the pasword or other authentications
  def deletable?
    !user.encrypted_password.to_s.empty? or user.authentications.count > 1
  end
end
