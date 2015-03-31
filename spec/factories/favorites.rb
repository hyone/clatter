# == Schema Information
#
# Table name: favorites
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  message_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_favorites_on_message_id              (message_id)
#  index_favorites_on_user_id                 (user_id)
#  index_favorites_on_user_id_and_message_id  (user_id,message_id) UNIQUE
#

FactoryGirl.define do
  factory :favorite do
    user
    message

    initialize_with {
      Favorite.where(
        user: user,
        message: message
      ).first_or_create
    }
  end
end
