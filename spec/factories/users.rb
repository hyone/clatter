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

    # if screen_name has already taken
    initialize_with { User.find_or_create_by(screen_name: screen_name) }
  end
end
