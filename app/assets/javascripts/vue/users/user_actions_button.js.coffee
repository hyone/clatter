Clatter.UserActionsButtonComponent = Vue.extend
  template: '#user-actions-button-template'
  replace: true

  data: ->
    user: undefined

  computed:
    canActions: ->
      !!Clatter.currentUser

    replyToUserText: ->
      I18n.t('views.users.user.message_to', { screen_name: @user.screen_name })

  methods:
    onClickReplyToUserButton: (event) ->
      @$dispatch('user-actions-button.click-user-reply-button', event, @user.screen_name)
