Clatter.FollowButtonComponent = Vue.extend
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
      unless Clatter.currentUser                 then 2
      # Current user page
      else if @user.id == Clatter.currentUser.id then 1
      # have not followed (follow button)
      else if !@user.follow.id                      then 2
      # have followed (unfollow button)
      else 3

    setupAjaxEventListeners: ->
      $(@$el).on 'ajax:success', (event, data, status, xhr) =>
        unless data.response.status == 'success'
          @$dispatch '_app.alert', event, data.response
          return false

        json = data.results.follow
        inc  = if data.response.request_method is "DELETE" then -1 else 1
        @updateButtonStatus(json)
        @updateUserStat(json, inc)

      $(@$el).on 'ajax:error', (event, xhr, status, error) =>
        @$dispatch '_app.alert', event,
          status: status
          message: "#{I18n.t('views.alert.failed_follow_user', user: @user.screen_name)}: #{error}"

      $(@$el).on 'ajax:complete', (event, data, status, xhr) =>
        $(event.target).find('button[type="submit"]').removeAttr('disabled')

      $(@$el).on 'ajax:before', (event, data, status, xhr) =>
        $(event.target).find('button[type="submit"]').attr('disabled', 'disabled')

    updateButtonStatus: (data) ->
      @user.follow.id = switch data.status
        when 'follow'   then data.id
        when 'unfollow' then null

    updateUserStat: (data, inc) ->
      return unless Clatter.profileUser
      options = switch Clatter.profileUser.id
        when data.follower.id      then { following: inc }
        when data.followed_user.id then { followers: inc }
      @$dispatch('_app.update-stats', event, options)
