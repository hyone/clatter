Clatter.ContentNavigationComponent = Vue.extend
  template: '#content-navigation-template'
  replace: true

  components:
    'follow-button': Clatter.FollowButtonComponent
    'user-actions-button': Clatter.UserActionsButtonComponent

  data: ->
    user: Clatter.profileUser

  events:
    'favorite.update-stats': 'onUpdateStats'
    'follow.update-stats': 'onUpdateStats'

  methods:
    isActiveMenu: (url) ->
      @$interpolate(url) is location.pathname

    updateStats: ({messages, following, followers, favorites}) ->
      @user.messages_count  += messages  if messages?
      @user.following_count += following if following?
      @user.followers_count += followers if followers?
      @user.favorites_count += favorites if favorites?

    onUpdateStats: (event, args) ->
      @updateStats(args)
      false
