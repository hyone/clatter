module MessagesHelper
  # message model fields that must preload
  def preload_fields
    if user_signed_in?
      [:user, :users_replied_to, :favorite_relationships, :retweet_relationships]
    else
      [:user, :users_replied_to]
    end
  end
end
