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

      # Message
      can [:create, :destroy], Message, user: user

      # Follow
      can [:create, :destroy], Follow, follower: user

      # Favorite
      can [:create, :destroy], Favorite, user: user

      # Reply
      can [:create, :destroy], Reply, user: user

      # Retweet
      can [:create, :destroy], Retweet, user: user
    end
  end
end
