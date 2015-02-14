json.partial! 'shared/response', status: @status, messages: @response_messages

json.results do
  json.follow do
    json.id nil
    json.status 'unfollow'

    json.follower do
      json.extract! @follow.follower, :id, :screen_name
      json.following_count Follow.where(follower: @follow.follower).count
      json.followers_count Follow.where(followed: @follow.follower).count
    end
    json.followed_user do
      json.extract! @follow.followed, :id, :screen_name
      json.following_count Follow.where(follower: @follow.followed).count
      json.followers_count Follow.where(followed: @follow.followed).count
    end
  end
end
