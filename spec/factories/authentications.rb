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

FactoryGirl.define do
  factory :authentication do
    user
    provider 'Twitter'
    sequence(:uid) { |i| i }
    account_name { Faker::Internet.user_name }
    url { Faker::Internet.url }
  end
end
