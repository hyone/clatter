FactoryGirl.define do
  factory :authentication do
    user
    provider 'Twitter'
    sequence(:uid) { |i| i }
    account_name { Faker::Internet.user_name }
    url { Faker::Internet.url }
  end
end
