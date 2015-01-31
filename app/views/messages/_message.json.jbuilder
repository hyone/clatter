json.extract! message, :id, :text, :created_at
json.html_text replace_reply_at_to_user_link(message)

json.created_at_human time_ago_in_words(message.created_at)

json.user do
  json.partial! message.user
end

json.permissions do
  json.read    can?(:read, message)
  json.destroy can?(:destroy, message)
end
