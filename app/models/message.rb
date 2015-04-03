# == Schema Information
#
# Table name: messages
#
#  id              :integer          not null, primary key
#  text            :string           not null
#  user_id         :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  favorited_count :integer          default(0), not null
#  retweeted_count :integer          default(0), not null
#
# Indexes
#
#  index_messages_on_user_id                 (user_id)
#  index_messages_on_user_id_and_created_at  (user_id,created_at)
#

class Message < ActiveRecord::Base
  belongs_to :user

  validates :user, presence: true
  validates :text,
    presence: true,
    length: { maximum: 140 }

  counter_culture :user, column_name: 'messages_count'

  scope :newer, ->() {
    order(created_at: :desc)
  }


  concerning :Replyable do
    included do
      after_save :extract_reply_relationships

      # reply relationships that the message send to
      has_many :reply_relationships, class_name: 'Reply', dependent: :destroy
      has_many :users_replied_to, through: :reply_relationships, source: :to_user
      has_many :parents, through: :reply_relationships, source: :to_message

      # reply relationships that the message received from
      has_many :reverse_reply_relationships, foreign_key: 'to_message_id',
                                             class_name: 'Reply'
      has_many :replies, through: :reverse_reply_relationships, source: :message

      # virtual field to set the id of message replied to
      attr_accessor :message_id_replied_to
    end

    def parent
      parents.first
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
        case filter.to_s
        when 'following'
          joins(:reply_relationships).where(
            replies: { to_user_id: user.id },
            user_id: Follow.where(follower: user).select(:followed_id)
          ).newer()
        else
          joins(:reply_relationships).merge(
            Reply.where(to_user_id: user.id)
          ).newer()
        end
      end

      def descendants_of(message, limit = 50)
        sql = <<-EOC
          WITH RECURSIVE rec (id, child, depth) AS (
            SELECT messages.id, replies.message_id AS child, 1
              FROM messages
              INNER JOIN replies ON messages.id = replies.to_message_id
              GROUP BY messages.id, replies.message_id
              HAVING messages.id = :id
            UNION ALL
            SELECT m.id, r.message_id AS child, depth+1
              FROM rec, messages AS m
              INNER JOIN replies AS r ON m.id = r.to_message_id
              GROUP BY m.id, r.message_id, depth+1, rec.child
              HAVING m.id = rec.child
          )
          SELECT messages.*, rec.id as parent, rec.depth
            FROM rec
            INNER JOIN messages ON messages.id = rec.child
            LIMIT :limit
        EOC
        self.execute [sql, id: message.id, limit: limit]
      end

      def ancestors_of(message, limit = 30)
        sql = <<-EOC
          WITH RECURSIVE rec (id, parent) AS (
            SELECT messages.id, replies.to_message_id AS parent
              FROM messages
              INNER JOIN replies ON messages.id = replies.message_id
              GROUP BY messages.id, replies.to_message_id
              HAVING messages.id = :id
            UNION ALL
            SELECT m.id, r.to_message_id AS parent
              FROM rec, messages AS m
              INNER JOIN replies AS r ON m.id = r.message_id
              GROUP BY m.id, r.to_message_id, rec.parent
              HAVING m.id = rec.parent
          )
          SELECT messages.*, rec.id as child
            FROM rec
            INNER JOIN messages ON messages.id = rec.parent
            LIMIT :limit
        EOC
        self.execute [sql, id: message.id, limit: limit]
      end
    end
  end


  concerning :Favoritedable do
    include HasManyThrough

    included do
      has_many_through 'favorite', source: :user, relationship: :favorite_users
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


  concerning :UserFollowable do
    class_methods do
      def arel_messages_from_self_and_followed_users_of(user)
        messages = Message.arel_table
        messages.where( messages[:user_id].in(
          User.self_and_followed_users_ids_of(user).arel
        ) )
      end
    end
  end


  concerning :Timelinable do
    include Message::Retweetedable
    include Message::UserFollowable

    class_methods do
      def timeline_of(user)
        users    = User.arel_table
        messages = Message.arel_table
        retweets = Retweet.arel_table
        replies  = Reply.arel_table

        self.union(
          # meeesages that is
          # - from the user or his followed users
          # - non replies or replies to the user
          self.arel_messages_from_self_and_followed_users_of(user)
            .project(*MESSAGE_COLUMNS)
            .join(replies, Arel::Nodes::OuterJoin)
            .on(replies[:message_id].eq(messages[:id]))
            .where(
              replies[:id].eq(nil).or(
                messages[:user_id].eq(user.id).or(
                  replies[:to_user_id].eq(user.id)
                )
              )
            ),
          self.arel_others_retweets_from_self_and_followed_users_of(user)
            .project(*RETWEET_COLUMNS)
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


  concerning :Searchable do
    include Message::UserFollowable

    included do
      scope :from_self_and_followed_users, -> (user) {
        self.execute(
          self.arel_messages_from_self_and_followed_users_of(user).project('messages.*')
        )
      }
    end

    class_methods do
      def ransackable_scopes(auth_object = nil)
        %i[from_self_and_followed_users]
      end
    end
  end
end
