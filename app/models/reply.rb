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

class Reply < ActiveRecord::Base
  belongs_to :message
  belongs_to :to_message, class_name: 'Message'
  belongs_to :to_user, class_name: 'User'

  validates :message, presence: true
  validates :to_user, presence: true
end
