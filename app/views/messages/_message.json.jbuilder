json.extract! message, :id, :text, :created_at

json.user do
  json.partial! message.user
end

json.permissions do
  json.read     can?(:read, message)
  json.destroy  can?(:destroy, message)
  json.retweet  can?(:create, Retweet.new(user: current_user, message: message))
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
