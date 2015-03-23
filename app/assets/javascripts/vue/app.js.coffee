Clatter.appVM = new Vue
  el: '#app'

  data:
    messages: Clatter.messages?.messages
    users: Clatter.users
    search: Clatter.search || {}
    uri: URI(location.href)

  computed:
    hasMessages: ->
      @messages.length > 0

    hasUsers: ->
      @users.length > 0

    searchKeywords: ->
      @search.text?.split(/\s+/)

    currentUser: ->
      Clatter.currentUser

  components:
    'alert': Clatter.AlertComponent
    'content-main-message-form': Clatter.ContentMainMessageFormComponent
    'content-navigation': Clatter.ContentNavigationComponent
    'message': Clatter.MessageComponent
    'message-panel': Clatter.MessagePanelComponent
    'modal-dialog': Clatter.ModalDialogComponent
    'navigation': Clatter.NavigationComponent
    'user': Clatter.UserComponent
    'user-panel': Clatter.UserPanelComponent

  events:
    '_app.update-stats': 'onUpdateStats'
    '_message.created': 'onMessageCreated'
    '_message.deleted': 'onMessageDeleted'
    '_message.click-reply-button': 'onClickReplyToMessageButton'
    '_navigation.click-new-message-button': 'onClickNewMessageButton'
    '_user.click-reply-button': 'onClickReplyToUserButton'
    '_app.alert': 'onAlert'

  created: ->
    @initMoment()

  ready: ->
    window.rendered = true

  methods:
    initMoment: ->
      # lang
      lang = $('html').prop('lang')
      moment.locale(lang)
      # timezone
      timezone = $('html').data('timezone')
      moment.tz.setDefault(timezone)

    isActiveMenu: (url) ->
      @$interpolate(url) is location.pathname

    addMessage: (message) ->
      @messages.unshift(message)

    showAlert: (status, message, details) ->
      @$.alert.show(status, message, details)

    parametersWith: (params) ->
      @uri.clone().setQuery(params).toString()

    onClickNewMessageButton: (args...) ->
      @$broadcast('message.click-new-button', args...)
      false

    onClickReplyToUserButton: (args...) ->
      @$broadcast('user.click-reply-button', args...)
      false

    onClickReplyToMessageButton: (args...) ->
      @$broadcast('message.click-reply-button', args...)
      false

    onUpdateStats: (args...) ->
      @$broadcast('app.update-stats', args...)
      false

    onMessageCreated: (event, message) ->
      if Clatter.profileUser and
         Clatter.currentUser and
         Clatter.profileUser.id == Clatter.currentUser.id and
         Clatter.messages?.page == 1
        @addMessage(message)
        # @showAlert('success', 'Message Created!')
      @$broadcast('message.created', event, message)
      false

    onMessageDeleted: (event, message) ->
      @messages.$remove(message)
      @showAlert('success', I18n.t('views.alert.success_delete_message'))
      @$broadcast('message.deleted', event, message)
      false

    onAlert: (args...) ->
      @$broadcast('app.alert', args...)
      false
