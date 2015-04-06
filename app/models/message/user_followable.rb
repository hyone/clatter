class Message
  module UserFollowable
    extend ActiveSupport::Concern

    class_methods do
      def arel_messages_from_self_and_followed_users_of(user)
        messages = Message.arel_table
        messages.where(
          messages[:user_id].in(
            User.self_and_followed_users_ids_of(user).arel
          )
        )
      end
    end
  end
end
