# == Schema Information
#
# Table name: replies
#
#  id            :integer          not null, primary key
#  message_id    :integer          not null
#  to_user_id    :integer          not null
#  to_message_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_replies_on_message_id     (message_id)
#  index_replies_on_to_message_id  (to_message_id)
#  index_replies_on_to_user_id     (to_user_id)
#

FactoryGirl.define do
  factory :reply do
    message
    association :to_message, factory: :message
    association :to_user, factory: :user
  end
end
