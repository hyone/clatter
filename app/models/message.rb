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

  class << self
    def timeline_of(user)
      user.messages.newer()
      # includes(:reply_relationships).where(
        # Message.arel_table[:user_id].eq(user.id).or(
          # Reply.arel_table[:to_user_id].eq(user.id)
        # )
      # ).references(:reply_relationships)
       # .newer()
    end

    def mentions_of(user)
      includes(:reply_relationships).where(
        Reply.arel_table[:to_user_id].eq(user.id)
      ).references(:reply_relationships)
      .newer()
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
