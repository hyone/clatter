TwitterApp.FollowButtonComponent = Vue.extend
  template: '#follow-button-template'

  replace: true

  data: ->
    user: undefined

  computed:
    isEditProfileButton:  -> @selectButton() == 1
    isFollowButton:       -> @selectButton() == 2
    isUnfollowButton:     -> @selectButton() == 3
    canFollow: ->
      @user.permissions.follow

  compiled: ->
    @setupAjaxEventListeners()

  methods:

    selectButton: ->
      # Not login
      unless TwitterApp.currentUser                 then 2
      # Current user page
      else if @user.id == TwitterApp.currentUser.id then 1
      # have not followed (follow button)
      else if !@user.follow.id                      then 2
      # have followed (unfollow button)
      else 3

    setupAjaxEventListeners: ->
      $(@$el).on 'ajax:success', (event, data, status, xhr) =>
        unless data.response.status == 'success'
          @$dispatch 'app.alert', event, data.response
          return false

        json = data.results.follow
        inc  = if data.response.request_method is "DELETE" then -1 else 1
        @updateButtonStatus(json)
        @updateUserStat(json, inc)

      $(@$el).on 'ajax:error', (event, xhr, status, error) =>
        @$dispatch 'app.alert', event,
          status: status
          message: "#{I18n.t('views.alert.failed_follow', user: @user.screen_name)}: #{error}"

      $(@$el).on 'ajax:complete', (event, data, status, xhr) =>
        $(event.target).find('button[type="submit"]').removeAttr('disabled')

      $(@$el).on 'ajax:before', (event, data, status, xhr) =>
        $(event.target).find('button[type="submit"]').attr('disabled', 'disabled')

    updateButtonStatus: (data) ->
      switch data.status
        when 'follow'
          @user.follow.id = data.id
        when 'unfollow'
          @user.follow.id = null

    updateUserStat: (data, inc) ->
      return unless TwitterApp.profileUser
      switch TwitterApp.profileUser.id
        when data.follower.id
          @$dispatch('follow.update-stats', event, following: inc)
        when data.followed_user.id
          @$dispatch('follow.update-stats', event, followers: inc)
