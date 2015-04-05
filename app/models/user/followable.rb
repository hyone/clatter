class User
  module Followable
    extend ActiveSupport::Concern

    included do
      # following relationships
      has_many :follow_relationships, foreign_key: 'follower_id',
                                      class_name: 'Follow',
                                      dependent: :destroy
      has_many :followed_users, through: :follow_relationships, source: :followed

      # followers relationships
      has_many :reverse_follow_relationships, foreign_key: 'followed_id',
                                              class_name: 'Follow',
                                              dependent: :destroy
      has_many :followers, through: :reverse_follow_relationships, source: :follower
    end

    def followed_users_newer
      followed_users.merge(Follow.order(created_at: :desc))
    end

    def followers_newer
      followers.merge(Follow.order(created_at: :desc))
    end

    def following?(other_user)
      follow_relationships.find_by(followed_id: other_user.id)
    end

    def follow!(other_user)
      follow_relationships.create!(followed_id: other_user.id)
    end

    def unfollow!(other_user)
      follow_relationships.find_by(followed_id: other_user.id).destroy!
    end

    class_methods do
      def self_and_followed_users_ids_of(user)
        follows = Follow.arel_table
        union(
          arel_followed_users_of(user).project(follows[:followed_id].as('id')),
          arel_self_of(user).project(:id)
        )
      end

      def self_and_followed_users_of(user)
        users = User.arel_table
        User.where(users[:id].in(self_and_followed_users_ids_of(user).arel))
      end

      def arel_followed_users_of(user)
        users   = User.arel_table
        follows = Follow.arel_table

        users.join(follows).on(
          users[:id].eq(follows[:follower_id])
        ).where(
          users[:id].eq(user.id)
        )
      end

      def arel_self_of(user)
        users = User.arel_table
        users.where(users[:id].eq(user.id))
      end
    end
  end
end
