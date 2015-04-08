Clatter.UserActionsButtonComponent = Vue.extend
  template: '#user-actions-button-template'
  replace: true

  data: ->
    user: undefined

  computed:
    canActions: ->
      !!Clatter.currentUser

    replyToUserText: ->
      I18n.t('vue.user_actions_button.message_to', { screen_name: @user.screen_name })

  methods:
    onClickReplyToUserButton: (event) ->
      @$dispatch('_user.click-reply-button', event, @user)
