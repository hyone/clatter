$ ->
  updateUserProfileStat = (following, followers) ->
    $('.content-navigation-following .nav-value').html(following) if following?
    $('.content-navigation-followers .nav-value').html(followers) if followers?

  updateFollowStatus = (button, json) ->
    # toggle follow/unfollow button
    $(button).closest('div.follow-or-unfollow-button')
      .replaceWith(json.button_html)

    # when on follower or followed_user profile page
    userId = $('#profile-user-data').data('user-id')
    if userId?
      switch userId
        when json.follower.id
          updateUserProfileStat(json.follower.following_count)
        when json.followed_user.id
          updateUserProfileStat(null, json.followed_user.followers_count)


  $(document)
    .on 'ajax:success', '.follow-button', (event, data, status, xhr) ->
      updateFollowStatus(event.target, data.relationship)
    .on 'ajax:success', '.unfollow-button', (event, data, status, xhr) ->
      updateFollowStatus(event.target, data.relationship)
