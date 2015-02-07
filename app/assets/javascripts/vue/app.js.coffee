TwitterApp.appVM = new Vue
  el: '#app'

  data:
    messages: TwitterApp.messages?.messages
    users: TwitterApp.users

  components:
    'alert': TwitterApp.AlertComponent
    'content-main-message-form': TwitterApp.ContentMainMessageFormComponent
    'content-navigation': TwitterApp.ContentNavigationComponent
    'message': TwitterApp.MessageComponent
    'modal-dialog': TwitterApp.ModalDialogComponent
    'navigation': TwitterApp.NavigationComponent
    'user-panel': TwitterApp.UserPanelComponent

  events:
    'follow.update-stats': 'onUpdateStats'
    'message.created': 'onMessageCreated'
    'message.deleted': 'onMessageDeleted'
    'message.on-click-reply-button': 'onClickReplyToMessageButton'
    'user-actions-button.click-user-reply-button': 'onClickReplyToUserButton'
    'navigation.click-new-message-button': 'onClickNewMessageButton'
    'app.alert': 'onAlert'

  ready: ->
    window.rendered = true

  methods:
    addMessage: (message) ->
      @messages.unshift(message)
      @messages.pop()

    showAlert: (status, message, details) ->
      @$.alert.show(status, message, details)


    onClickNewMessageButton: (args...) ->
      @$.modalDialog.onOpenNew(args...)
      false

    onClickReplyToUserButton: (args...) ->
      @$.modalDialog.onOpenUserReply(args...)
      false

    onClickReplyToMessageButton: (args...) ->
      @$.modalDialog.onOpenMessageReply(args...)
      false

    onMessageCreated: (event, message) ->
      if TwitterApp.profileUser and
         TwitterApp.currentUser and
         TwitterApp.profileUser.id == TwitterApp.currentUser.id and
         TwitterApp.messages?.page == 1
        @addMessage(message)
        # @showAlert('success', 'Message Created!')
      @$.contentMainMessageForm?.close()
      false

    onMessageDeleted: (event, message) ->
      @messages.$remove(message)
      @showAlert('success', I18n.t('views.alert.success_delete_message'))
      false

    onUpdateStats: (event, args...) ->
      @$.contentNavigation?.updateStats(args...)
      false

    onAlert: (event, data) ->
      @showAlert(data.status, data.message, data.details)
      @$.modalDialog.hide()
      false
