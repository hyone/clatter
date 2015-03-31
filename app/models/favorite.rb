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

class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :message

  validates :user,    presence: true
  validates :message, presence: true

  counter_culture :message, column_name: 'favorited_count'
  counter_culture :user, column_name: 'favorites_count'
end
