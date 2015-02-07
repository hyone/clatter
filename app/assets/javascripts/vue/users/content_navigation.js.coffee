TwitterApp.ContentNavigationComponent = Vue.extend
  template: '#content-navigation-template'
  replace: true

  components:
    'follow-button': TwitterApp.FollowButtonComponent
    'user-actions-button': TwitterApp.UserActionsButtonComponent

  data: ->
    user: TwitterApp.profileUser

  events:
    'follow.update-stats': 'onUpdateStats'

  methods:
    updateStats: (following, followers) ->
      @user.following_count = following if following?
      @user.followers_count = followers if followers?

    onUpdateStats: (event, following, followers) ->
      @updateStats(following, followers)
      false
