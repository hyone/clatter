class Message
  module Searchable
    extend ActiveSupport::Concern
    include Message::UserFollowable

    included do
      scope :from_self_and_followed_users, lambda { |user|
        execute(
          arel_messages_from_self_and_followed_users_of(user).project('messages.*')
        )
      }
    end

    class_methods do
      def ransackable_scopes(_auth_object = nil)
        %i( from_self_and_followed_users )
      end
    end
  end
end
