follow ||= false
stats  ||= false

json.extract! user, :id, :screen_name, :name, :url, :created_at
json.profile_image_url        user.profile_image.normal.url
json.profile_image_url_normal user.profile_image.normal.url
json.profile_image_url_small  user.profile_image.small.url

if stats
  json.messages_count  user.messages_count
  json.favorites_count user.favorites_count
  json.following_count user.following_count
  json.followers_count user.followers_count
end

if follow
  json.follow do
    json.id current_user ? current_user.following?(user).try(:id) : nil
  end
end
