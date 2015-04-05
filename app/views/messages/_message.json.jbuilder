detail ||= false

json.extract! message, :id, :text, :created_at

json.user do
  if detail
    json.partial! message.user, follow: true
  else
    json.partial! message.user
  end
end

json.permissions do
  json.read can?(:read, message)
  json.destroy can?(:destroy, message)
  json.retweet can?(:create, Retweet.new(user: current_user, message: message))
  json.favorite can?(:create, Favorite.new(user: current_user, message: message))
end

json.reply_users do
  json.array! message.users_replied_to, partial: 'users/user', as: :user
end

json.favorited do
  json.id user_signed_in? ? message.favorited_by(current_user) : nil
end

json.retweeted do
  json.id user_signed_in? ? message.retweeted_by(current_user) : nil

  if message.try(:retweet_user_id)
    json.user do
      json.id message.retweet_user_id
      json.screen_name message.retweet_user_screen_name
    end
  end
end

json.favorited_count message.favorited_count
json.retweeted_count message.retweeted_count

if detail
  json.favorite_users do
    json.array! message.favorite_users.limit(30), partial: 'users/user', as: :user
  end

  json.retweet_users do
    json.array! message.retweet_users.limit(30), partial: 'users/user', as: :user
  end

  json.parents do
    ancestors = Message.ancestors_of(message).includes(*preload_fields)
    json.array! ancestors, partial: 'messages/message', as: :message
  end

  json.replies do
    descendants = Message.descendants_of(message).includes(*preload_fields)
    json.array! descendants, partial: 'messages/message', as: :message
  end
end
