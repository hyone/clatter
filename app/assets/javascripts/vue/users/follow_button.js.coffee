TwitterApp.FollowButtonComponent = Vue.extend
  template: '#follow-button-template'

  replace: true

  data: ->
    user: undefined

  computed:
    isRequireLoginButton: -> @selectButton() == 1
    isEditProfileButton:  -> @selectButton() == 2
    isFollowButton:       -> @selectButton() == 3
    isUnfollowButton:     -> @selectButton() == 4

  compiled: ->
    @setupAjaxEventListeners()

  methods:
    selectButton: ->
      # Not login
      unless TwitterApp.currentUser                 then 1
      # Current user page
      else if @user.id == TwitterApp.currentUser.id then 2
      # have not followed (follow button)
      else if !@user.follow.id                      then 3
      # have followed (unfollow button)
      else 4

    setupAjaxEventListeners: ->
      $(@$el).on 'ajax:success', (event, data, status, xhr) =>
        unless data.response.status == 'success'
          return @$dispatch 'app.alert', event, data.response

        json = data.results.follow
        @updateButtonStatus(json)
        @updateUserStat(json)

      $(@$el).on 'ajax:error', (event, xhr, status, error) =>
        @$dispatch 'app.alert', event,
          status: status
          message: "#{I18n.t('views.alert.failed_follow', user: @user.screen_name)}: #{error}"

      $(@$el).on 'ajax:complete', (event, data, status, xhr) =>
        $(event.target).find('button[type="submit"]').removeAttr('disabled')

      $(@$el).on 'ajax:before', (event, data, status, xhr) =>
        $(event.target).find('button[type="submit"]').attr('disabled', 'disabled')

    updateButtonStatus: (data) ->
      @user.follow.id = data.follow_id

    updateUserStat: (data) ->
      return unless TwitterApp.profileUser
      switch TwitterApp.profileUser.id
        when data.follower.id
          @$dispatch('follow.update-stats', event, following: data.follower.following_count)
        when data.followed_user.id
          @$dispatch('follow.update-stats', event, followers: data.followed_user.followers_count)
