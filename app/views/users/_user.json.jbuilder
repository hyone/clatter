follow ||= false
stats  ||= false

json.extract! user, :id, :screen_name, :name, :url, :created_at
json.profile_image_url        user.profile_image.normal.url
json.profile_image_url_normal user.profile_image.normal.url
json.profile_image_url_small  user.profile_image.small.url

if stats
  json.messages_count user.messages.count
  json.following_count user.followed_users.count
  json.followers_count user.followers.count
end

if follow
  json.follow do
    json.id current_user ? current_user.follow_relationships.find_by(followed: user.id).try(:id) : nil
  end
end
