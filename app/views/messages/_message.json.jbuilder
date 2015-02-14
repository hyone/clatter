json.extract! message, :id, :text, :created_at
json.html_text replace_reply_at_to_user_link(message)

json.created_at_human time_ago_in_words(message.created_at)

json.favorited do
  json.id user_signed_in? ? message.favorited_by(current_user).try(:id) : nil
end

json.user do
  json.partial! message.user
end

json.permissions do
  json.read    can?(:read, message)
  json.destroy can?(:destroy, message)
end

json.favorited_count message.favorite_relationships.count
