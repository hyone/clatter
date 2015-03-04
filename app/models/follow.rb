class Follow < ActiveRecord::Base
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'

  validates :follower, presence: true
  validates :followed, presence: true

  counter_culture :followed, column_name: 'followers_count'
  counter_culture :follower, column_name: 'following_count'
end
