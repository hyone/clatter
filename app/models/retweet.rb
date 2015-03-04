class Retweet < ActiveRecord::Base
  belongs_to :user
  belongs_to :message

  validates :user,    presence: true
  validates :message, presence: true

  counter_culture :message, column_name: 'retweeted_count'
end
