class Message < ActiveRecord::Base
  belongs_to :user

  validates :user, presence: true
  validates :text,
    presence: true,
    length: { maximum: 140 }


  scope :newer, ->() {
    order(created_at: :desc)
  }


  concerning :Repliable do
    included do
      after_save :extract_reply_relationships

      # reply relationships that the message send to
      has_many :reply_relationships, class_name: 'Reply', dependent: :destroy
      has_many :users_replied_to, through: :reply_relationships, source: :to_user

      # reply relationships that the message received from
      has_many :reverse_reply_relationships, foreign_key: 'to_message_id',
                                             class_name: 'Reply',
                                             dependent: :destroy

      # virtual field to set the id of message replied to
      attr_accessor :message_id_replied_to
    end

    def parent
      reply_relationships.first.to_message
    end

    def reply?
      not reply_relationships.empty?
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

    class_methods do
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
  end


  concerning :Favoritedable do
    included do
      has_many :favorite_relationships, class_name: 'Favorite', dependent: :destroy
      has_many :favorited_users, through: :favorite_relationships, source: :user
    end

    def favorited_by(user)
      # NOTE:
      # the way that do not execute SQL if have eager loaded.
      # do not use 'pluck' here, because pluck always execute SQL
      favorite_relationships.map { |m| [m.user_id, m.id] }.assoc(user.id).try(:second)
      # # 'find_by' always execute SQL
      # favorite_relationships.find_by(user: user)
    end
  end


  concerning :Retweetedable do
    included do
      has_many :retweet_relationships, class_name: 'Retweet', dependent: :destroy
      has_many :retweet_users, through: :retweet_relationships, source: :user
    end

    def retweeted?
      retweet_relationships.any?
    end

    def retweeted_by(user)
      retweet_relationships.map { |m| [m.user_id, m.id] }.assoc(user.id).try(:second)
      # retweet_relationships.find_by(user: user)
    end

    MESSAGE_COLUMNS = [
      'messages.*',
      'messages.created_at AS order_datetime',
      'NULL AS retweeted_at',
      'NULL AS retweet_id',
      'NULL AS retweet_user_id',
      'NULL AS retweet_user_screen_name'
    ]
    RETWEET_COLUMNS = [
      'messages.*',
      'retweets.created_at AS order_datetime',
      'retweets.created_at AS retweeted_at',
      'retweets.id AS retweet_id',
      'users.id AS retweet_user_id',
      'users.screen_name AS retweet_user_screen_name'
    ]

    class_methods do
      def with_retweets_of(user)
        self.union(
          arel_messages_of(user).project(*MESSAGE_COLUMNS),
          arel_retweets_of(user).project(*RETWEET_COLUMNS)
        ).order('order_datetime desc')
      end

      def with_retweets_without_replies_of(user)
        self.union(
          arel_messages_without_replies_of(user).project(*MESSAGE_COLUMNS),
          arel_retweets_of(user).project(*RETWEET_COLUMNS)
        ).order('order_datetime desc')
      end


      def arel_messages_of(user)
        messages = Message.arel_table
        messages.where(messages[:user_id].eq(user.id))
      end

      def arel_messages_without_replies_of(user)
        messages = Message.arel_table
        replies  = Reply.arel_table

        messages
        .join(replies, Arel::Nodes::OuterJoin)
        .on(messages[:id].eq(replies[:message_id]))
        .where(
          messages[:user_id].eq(user.id).and(
            replies[:id].eq(nil)
          )
        )
      end

      def arel_retweets_of(user)
        users    = User.arel_table
        messages = Message.arel_table
        retweets = Retweet.arel_table

        messages
        .join(retweets).on(messages[:id].eq(retweets[:message_id]))
        .join(users).on(users[:id].eq(retweets[:user_id]))
        .where(users[:id].eq(user.id))
      end
    end
  end


  concerning :Timelinable do
    class_methods do
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
    end
  end 
end
