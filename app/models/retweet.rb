# == Schema Information
#
# Table name: retweets
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  message_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_retweets_on_message_id              (message_id)
#  index_retweets_on_user_id                 (user_id)
#  index_retweets_on_user_id_and_message_id  (user_id,message_id) UNIQUE
#

class Retweet < ActiveRecord::Base
  belongs_to :user
  belongs_to :message

  validates :user,    presence: true
  validates :message, presence: true

  counter_culture :message, column_name: 'retweeted_count'
end
