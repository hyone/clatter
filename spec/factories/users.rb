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

    # if screen_name or email has already taken
    initialize_with {
      User.where( User.arel_table[:screen_name].eq(screen_name).or(
        User.arel_table[:email].eq(email)
      ) ).first_or_create do |u|
        u.screen_name = screen_name
        u.email = email
      end
    }
  end
end
