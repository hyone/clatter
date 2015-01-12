class Reply < ActiveRecord::Base
  belongs_to :message
  belongs_to :to_message, class_name: 'Message'
  belongs_to :to_user, class_name: 'User'

  validates :message, presence: true
  validates :to_user, presence: true
end
