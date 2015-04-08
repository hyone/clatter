# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  screen_name            :string           not null
#  name                   :string           not null
#  description            :string(160)
#  url                    :string
#  profile_image          :string
#  messages_count         :integer          default(0), not null
#  following_count        :integer          default(0), not null
#  followers_count        :integer          default(0), not null
#  favorites_count        :integer          default(0), not null
#  time_zone              :string           default("UTC")
#  lang                   :string
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_screen_name           (screen_name) UNIQUE
#

FactoryGirl.define do
  factory :user do
    sequence(:screen_name) do |n|
      "#{ Faker::Internet.user_name(name, %w(_)).slice(0, 15 - n.to_s.length) }#{n}"
    end
    email { Faker::Internet.email }
    password { Faker::Internet.password(12) }
    password_confirmation { password }

    name { Faker::Name.name }
    description { Faker::Lorem.sentence(3) }
    sequence(:url) { |n| (n % 3).zero? ?  Faker::Internet.url : nil }

    # factory :admin do
    #   admin true
    # end

    # if screen_name or email has already taken
    initialize_with do
      User
        .where(User.arel_table[:screen_name]
                 .eq(screen_name)
                 .or(User.arel_table[:email].eq(email)))
        .first_or_create do |u|
          u.screen_name = screen_name
          u.email = email
        end
    end
  end
end
