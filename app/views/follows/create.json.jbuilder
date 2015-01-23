json.follow do
  json.follower do
    json.extract! @follower, :id, :screen_name
    json.following_count Follow.where(follower: @follower).count
    json.followers_count Follow.where(followed: @follower).count
  end
  json.followed_user do
    json.extract! @followed_user, :id, :screen_name
    json.following_count Follow.where(follower: @followed_user).count
    json.followers_count Follow.where(followed: @followed_user).count
  end
  json.button_html @html
end
