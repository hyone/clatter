TwitterApp.appVM = new Vue
  el: '#app'

  data:
    messages: TwitterApp.messages?.messages
    users: TwitterApp.users

  computed:
    hasMessages: ->
      @messages.length > 0

  components:
    'alert': TwitterApp.AlertComponent
    'content-main-message-form': TwitterApp.ContentMainMessageFormComponent
    'content-navigation': TwitterApp.ContentNavigationComponent
    'message': TwitterApp.MessageComponent
    'modal-dialog': TwitterApp.ModalDialogComponent
    'navigation': TwitterApp.NavigationComponent
    'user-panel': TwitterApp.UserPanelComponent

  events:
    'favorite.update-stats': 'onUpdateStats'
    'follow.update-stats': 'onUpdateStats'
    'message.created': 'onMessageCreated'
    'message.deleted': 'onMessageDeleted'
    'message.on-click-reply-button': 'onClickReplyToMessageButton'
    'user-actions-button.click-user-reply-button': 'onClickReplyToUserButton'
    'navigation.click-new-message-button': 'onClickNewMessageButton'
    'app.alert': 'onAlert'

  created: ->
    @initMoment()

  ready: ->
    window.rendered = true

  methods:
    initMoment: ->
      lang = $('html').prop('lang')
      moment.locale(lang)

    isActiveMenu: (url) ->
      @$interpolate(url) is location.pathname

    addMessage: (message) ->
      @messages.unshift(message)

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
