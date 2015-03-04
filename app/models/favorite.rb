class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :message

  validates :user,    presence: true
  validates :message, presence: true

  counter_culture :message, column_name: 'favorited_count'
  counter_culture :user, column_name: 'favorites_count'
end
