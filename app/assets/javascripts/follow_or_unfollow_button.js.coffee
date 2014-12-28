$ ->
  updateUserProfileStat = (following, followers) ->
    $('.content-navigation-following .nav-value').html(following)
    $('.content-navigation-followers .nav-value').html(followers)

  updateFollowStatus = (button, json) ->
    # update follow/unfollow button
    $(button).closest('div.follow-or-unfollow-button')
      .replaceWith(json.button_html)

    # when on follower or followed_user profile page
    $profile_block = $('#profile-user-data')
    if $profile_block.size() > 0
      userId = $profile_block.data('user-id')
      if userId in [json.follower.id, json.followed_user.id]
        updateUserProfileStat(
          json.followed_user.following_count,
          json.followed_user.followers_count,
        )


  $(document)
    .on 'ajax:success', '.follow-button', (event, data, status, xhr) ->
      updateFollowStatus(event.target, data.relationship)
    .on 'ajax:success', '.unfollow-button', (event, data, status, xhr) ->
      updateFollowStatus(event.target, data.relationship)
