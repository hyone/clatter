class Message < ActiveRecord::Base
  after_save :extract_reply_relationships

  belongs_to :user

  # reply relationships that the message send to
  has_many :reply_relationships, class_name: 'Reply', dependent: :destroy
  has_many :users_replied_to, through: :reply_relationships, source: :to_user

  # reply relationships that the message received from
  has_many :reverse_reply_relationships, foreign_key: 'to_message_id',
                                         class_name: 'Reply',
                                         dependent: :destroy

  # favorite relationships
  has_many :favorite_relationships, class_name: 'Favorite', dependent: :destroy
  has_many :favorited_users, through: :favorite_relationships, source: :user

  # virtual field to set the id of message replied to
  attr_accessor :message_id_replied_to

  validates :user, presence: true
  validates :text,
    presence: true,
    length: { maximum: 140 }


  scope :newer, ->() {
    order(created_at: :desc)
  }

  def parent
    reply_relationships.first.to_message
  end

  def reply?
    not reply_relationships.empty?
  end

  def favorited_by(user)
    favorite_relationships.find_by(user: user)
  end


  class << self
    def timeline_of(user)
      users    = User.arel_table
      messages = Message.arel_table
      replies  = Reply.arel_table
      follows  = Follow.arel_table

      # collect messages from followed users and the user himself
      Message.where(
        messages[:user_id].in(
          self.union(
            # followed users
            users.project(:followed_id).
              join(follows).on(
                users[:id].eq(follows[:follower_id])
              ).
              where(users[:id].eq(user.id)),
            # the user
            users.project(:id).where(users[:id].eq(user.id))
          ).arel
        )
      ).
      # and then, filter above by
      # - non-reply messages
      # - replies to the user
      # - messages of the user himself
      includes(:reply_relationships).where(
        replies[:id].eq(nil).or(
          replies[:to_user_id].eq(user.id).or(
            messages[:user_id].eq(user.id)
          )
        )
      ).references(:reply_relationships).
      newer()
    end

    def mentions_of(user, filter: nil)
      case filter
      when 'following'
        joins(:reply_relationships).where(
          replies: { to_user_id: user.id },
          user_id: Follow.where(follower: user).select(:followed_id)
          # # in case of using arel
          # Reply.arel_table[:to_user_id].eq(user.id).and(
          #   Message.arel_table[:user_id].in(
          #     Follow.where(follower: user).select(:followed_id).arel
          #   )
          # )
        ).newer()
      else
        joins(:reply_relationships).merge(
          Reply.where(to_user_id: user.id)
        ).newer()
      end
    end
  end


  private
  def extract_reply_relationships
    # # reset reply relationships
    # reply_relationships.delete_all()

    to_message = Message.find_by(id: message_id_replied_to)

    reply_screen_names = text.scan(/@(\w+)/).map {|m| m[0] }
    reply_screen_names.each do |screen_name|
      if user = User.find_by(screen_name: screen_name)
        Reply.find_or_create_by(
          message: self,
          to_user: user,
          to_message: to_message
        )
      end
    end
  end
end
