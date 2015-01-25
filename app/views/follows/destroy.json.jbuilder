json.status 'success'

json.follow do
  json.follow_status 'unfollow'
  json.follow_id 0

  json.follower do
    json.extract! @follower, :id, :screen_name
    json.following_count Follow.where(follower: @follower).count
    json.followers_count Follow.where(followed: @follower).count
  end
  json.followed_user do
    json.extract! @followed, :id, :screen_name
    json.following_count Follow.where(follower: @followed_user).count
    json.followers_count Follow.where(followed: @followed_user).count
  end
end
