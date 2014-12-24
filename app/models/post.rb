class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :reply_to, class_name: 'Post'

  validates :user, presence: true
  validates :text,
    presence: true,
    length: { maximum: 140 }

  scope :latest_order, ->() {
    order(created_at: :desc)
  }

  scope :latest_order_without_replies, ->() {
    where(reply_to: nil).order(created_at: :desc)
  }
end
