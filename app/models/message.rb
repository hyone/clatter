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

class Message < ActiveRecord::Base
  belongs_to :user

  validates :user, presence: true
  validates :text, presence: true,
                   length: { maximum: 140 }

  counter_culture :user, column_name: 'messages_count'

  scope :newer, lambda {
    order(created_at: :desc)
  }

  include Message::Replyable
  include Message::Favoritedable
  include Message::Retweetedable
  include Message::UserFollowable
  include Message::Timelinable
  include Message::Searchable
end
