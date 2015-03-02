class Ability
  include CanCan::Ability

  def initialize(user)
    case
    # guest user
    when user.nil?
      can :read, :all
    # logined user
    else
      can :read, :all

      # Follow
      can [:create, :destroy], Follow, follower: user

      # Message
      can [:create, :destroy], Message, user: user

      # Favorite
      can [:create, :destroy], Favorite, user: user

      # Reply
      can [:create, :destroy], Reply, user: user

      # Retweet
      can    :create, Retweet, user: user
      #   can't retweet own messages
      cannot :create, Retweet do |retweet|
        retweet.message.user and retweet.message.user == user
      end
      can :destroy, Retweet, user: user
    end
  end
end
