class Message
  module Retweetedable
    extend ActiveSupport::Concern
    include HasManyThrough

    included do
      has_many_through 'retweet', source: :user, relationship: :retweet_users
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
        union(
          arel_messages_of(user).project(*MESSAGE_COLUMNS),
          arel_retweets_of(user).project(*RETWEET_COLUMNS)
        ).order('order_datetime desc')
      end

      def with_retweets_without_replies_of(user)
        union(
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
end
