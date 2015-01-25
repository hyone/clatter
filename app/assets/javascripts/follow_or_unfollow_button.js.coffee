FollowOrUnfollowButton = Vue.extend
  template: '#follow-or-unfollow-button-template'

  data: ->
    isFollow: null
    followId: 0
    screenName: null
    userId: null

  compiled: ->
    @bindInit()
    @setupEventHandlers()

  methods:
    bindInit: ->
      @userId     = $(@$el).data('user-id')
      follow      = TwitterApp.follows[@userId]
      user        = TwitterApp.users[@userId]
      @isFollow   = follow['follow']
      @followId   = follow['follow-id']
      @screenName = user['screen_name']

    setupEventHandlers: ->
      $(@$el).on 'ajax:success', (event, data, status, xhr) =>
        unless data.status == 'success'
          return
        json = data.follow
        @updateButtonStatus(json)
        @updateUserStat(json)

      $(@$el).on 'ajax:complete', (event, data, status, xhr) =>
        $(event.target).find('button[type="submit"]').removeAttr('disabled')

      $(@$el).on 'ajax:before', (event, data, status, xhr) =>
        $(event.target).find('button[type="submit"]').attr('disabled', 'disabled')

    updateButtonStatus: (data) ->
      TwitterApp.follows[@userId]['follow']    = @isFollow = data.follow_status == 'follow'
      TwitterApp.follows[@userId]['follow-id'] = @followId = data.follow_id

    updateUserStat: (data) ->
      currentUserId = $('#profile-user-data').data('user-id')
      switch currentUserId
        when data.follower.id
          @$dispatch('follow-or-unfollow-button.update-stats', event, data.follower.following_count)
        when data.followed_user.id
          @$dispatch('follow-or-unfollow-button.update-stats', event, null, data.followed_user.followers_count)


Vue.component('follow-or-unfollow-button', FollowOrUnfollowButton)
