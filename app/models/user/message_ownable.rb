class User
  module MessageOwnable
    extend ActiveSupport::Concern

    included do
      has_many :messages, dependent: :destroy

      # reply relationships that the user received from
      has_many :reverse_reply_relationships, foreign_key: 'to_user_id',
                                             class_name: 'Reply',
                                             dependent: :destroy
      has_many :replies_received, through: :reverse_reply_relationships, source: :message
    end

    def timeline
      Message.timeline_of(self)
    end

    # replies that the user sent
    def replies
      messages.joins(:reply_relationships).distinct
    end

    def messages_without_replies
      messages.includes(:reply_relationships).where(replies: { id: nil }).references(:reply_relationships)
    end

    def mentions(filter: nil)
      Message.mentions_of(self, filter: filter)
    end
  end
end
