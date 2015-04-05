# == Schema Information
#
# Table name: authentications
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  provider     :string           not null
#  uid          :string           not null
#  account_name :string           not null
#  url          :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_authentications_on_user_id  (user_id)
#

class Authentication < ActiveRecord::Base
  belongs_to :user

  validates :provider, presence: true
  validates :uid, presence: true
  validates :user, presence: true
  validates :account_name, presence: true

  # be able to delete the authentication,
  # only when its user has the pasword or other authentications
  def deletable?
    !user.encrypted_password.to_s.empty? || user.authentications.count > 1
  end
end
