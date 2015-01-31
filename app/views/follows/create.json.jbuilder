json.response do
  json.status @status
  json.messages @messages
  json.date DateTime.now
end

json.results do
  json.follow do
    json.follow_status 'follow'
    json.follow_id @follow.id

    json.follower do
      json.extract! @follower, :id, :screen_name
      json.following_count Follow.where(follower: @follower).count
      json.followers_count Follow.where(followed: @follower).count
    end
    json.followed_user do
      json.extract! @followed, :id, :screen_name
      json.following_count Follow.where(follower: @followed).count
      json.followers_count Follow.where(followed: @followed).count
    end
  end
end
