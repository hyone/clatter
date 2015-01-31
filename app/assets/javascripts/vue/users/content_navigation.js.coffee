TwitterApp.ContentNavigationComponent = Vue.extend
  template: '#content-navigation-template'

  replace: true

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

Vue.component('content-navigation', TwitterApp.ContentNavigationComponent)
