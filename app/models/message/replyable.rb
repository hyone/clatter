class Message
  module Replyable
    extend ActiveSupport::Concern

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
      !reply_relationships.empty?
    end

    private

    def extract_reply_relationships
      # # reset reply relationships
      # reply_relationships.delete_all()

      to_message = Message.find_by(id: message_id_replied_to)

      reply_screen_names = text.scan(/@(\w+)/).map { |m| m[0] }
      reply_screen_names.each do |screen_name|
        user = User.find_by(screen_name: screen_name)
        next unless user

        Reply.find_or_create_by(
          message: self,
          to_user: user,
          to_message: to_message
        )
      end
    end

    class_methods do
      def mentions_of(user, filter: nil)
        case filter.to_s
        when 'following'
          joins(:reply_relationships).where(
            replies: { to_user_id: user.id },
            user_id: Follow.where(follower: user).select(:followed_id)
          ).newer
        else
          joins(:reply_relationships).merge(
            Reply.where(to_user_id: user.id)
          ).newer
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
        execute [sql, id: message.id, limit: limit]
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
        execute [sql, id: message.id, limit: limit]
      end
    end
  end
end
