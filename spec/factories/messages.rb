# == Schema Information
#
# Table name: messages
#
#  id              :integer          not null, primary key
#  text            :string           not null
#  user_id         :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  favorited_count :integer          default(0), not null
#  retweeted_count :integer          default(0), not null
#
# Indexes
#
#  index_messages_on_user_id                 (user_id)
#  index_messages_on_user_id_and_created_at  (user_id,created_at)
#

FactoryGirl.define do
  factory :message, aliases: [:reply_to] do
    user
    text { Faker::Lorem.sentence(3) }
    created_at { rand(0..240).hours.ago }

    trait :replyable do
      transient do
        reply_count 1
        users_replied_to nil
      end

      text do
        users  = users_replied_to || create_list(:user, reply_count)
        prefix = users.map { |u| "@#{u.screen_name}" }.join(' ')
        "#{prefix} #{ Faker::Lorem.sentence(2) }"
      end

      message_id_replied_to nil
    end

    # Call to like below:
    #
    # > FactoryGirl.create(:message_with_reply)
    #
    # specify the count of users which is replied to
    # > FactoryGirl.create(:message_with_reply, reply_count: 2)
    #
    # specify the users which is replied to
    # > FactoryGirl.create(:message_with_reply, users_replied_to: [User.find(1), User.find(5)])
    #
    # specify both user (send, receive)
    # > FactoryGirl.create(:message_with_reply, user: User.find(1), users_replied_to: [User.find(2)])
    #
    # specify the users and the message which is replied to
    # > FactoryGirl.create(:message_with_reply, users_replied_to: [User.find(1)], message_id_replied_to: 135)
    factory :message_with_reply, traits: [:replyable]
  end
end
