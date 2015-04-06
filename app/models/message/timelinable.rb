class Message
  module Timelinable
    extend ActiveSupport::Concern
    include Message::Retweetedable
    include Message::UserFollowable

    class_methods do
      def timeline_of(user)
        users    = User.arel_table
        messages = Message.arel_table
        retweets = Retweet.arel_table
        replies  = Reply.arel_table

        union(
          # meeesages that is
          # - from the user or his followed users
          # - non replies or replies to the user
          arel_messages_from_self_and_followed_users_of(user)
            .project(*self::MESSAGE_COLUMNS)
            .join(replies, Arel::Nodes::OuterJoin)
            .on(replies[:message_id].eq(messages[:id]))
            .where(
              replies[:id].eq(nil).or(
                messages[:user_id].eq(user.id).or(
                  replies[:to_user_id].eq(user.id)
                )
              )
            ),
          arel_others_retweets_from_self_and_followed_users_of(user)
            .project(*self::RETWEET_COLUMNS)
            .join(users).on(users[:id].eq(retweets[:user_id]))
        ).order('order_datetime desc')
      end

      # retweets that is
      # - retweet by the user and their followd users
      # - only retweeted messages of other user's (non self and non followed users) posting
      # - when message has multiple retweets, include only the first retweet
      def arel_others_retweets_from_self_and_followed_users_of(user)
        messages = Message.arel_table
        retweets = Retweet.arel_table

        # retweets and messages join condition
        join_cond = retweets[:message_id].eq(messages[:id])

        # collect retweet ids
        retweet_ids =
          retweets
          .project(retweets[:id].minimum)
          .join(messages).on(join_cond)
          .where(
            retweets[:user_id].in(User.self_and_followed_users_ids_of(user).arel)
            .and(
              messages[:user_id].not_in(User.self_and_followed_users_ids_of(user).arel)
            )
          )
          .group(retweets[:message_id])

        # return messages of that retweet ids
        messages
          .join(retweets).on(join_cond)
          .where(retweets[:id].in(retweet_ids))
      end
    end
  end
end
