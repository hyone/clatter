class Message
  module Favoritedable
    extend ActiveSupport::Concern
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
end
