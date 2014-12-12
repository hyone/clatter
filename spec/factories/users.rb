FactoryGirl.define do
  factory :user do
    sequence(:screen_name) { |n| "user#{n}" }
    email { Faker::Internet.email }
    password 'password'
    password_confirmation 'password'

    name { Faker::Internet.user_name }
    description { Faker::Lorem.sentence(3) }
    sequence(:url) { |n| (n % 3).zero? ?  Faker::Internet.url : nil }

    # factory :admin do
      # admin true
    # end
  end
end
