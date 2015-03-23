Clatter.ModalDialogComponent = Vue.extend
  template: '#modal-dialog-template'
  replace: true

  paramAttributes: ['foot-view', 'body-view']

  data: ->
    title: ''
    footView: undefined
    bodyView: undefined
    params: {}

  components:
    'modal-message-form': Clatter.ModalMessageFormComponent
    message:
      template: """
        <div v-component="inner"
             v-with="
              message:  params.message,
              prefix:   params.prefix,
              showFoot: params.showFoot
            ">
        </div>
      """
      components:
        inner: Clatter.MessageComponent

  events:
    'user.click-reply-button': 'onOpenReplyUser'
    'message.click-new-button': 'onOpenNewMessage'
    'message.click-reply-button': 'onOpenReplyMessage'
    'app.alert': 'hide'


  compiled: ->
    @setupModalEventListeners()

  methods:
    hide: ->
      $(@$el).modal('hide')

    open: ->
      $(@$el).modal('show')

    toggle: ->
      $(@$el).modal('toggle')

    clearBody: ->
      @bodyView = null

    setDefaultTitle: ->
      @title = I18n.t('views.modal_dialog.compose_new_message')

    setReplyTitle: (text) ->
      @title = I18n.t('views.modal_dialog.reply_to', name: text)

    setupModalEventListeners: ->
      $(@$el).on 'hidden.bs.modal', (event) =>
        @clearBody()
        @$broadcast 'message-form.reset', event

      $(@$el).on 'shown.bs.modal', (event) =>
        @$broadcast 'message-form.focus', event

      $(@$el).on 'ajax:success', (event, data, status, xhr) =>
        @hide()

    openNew: ->
      @setDefaultTitle()
      @open()

    openMessageReply: (message) ->
      @params =
        message: message
        prefix: 'parent-message'
        showFoot: false
      @bodyView = 'message'
      @setReplyTitle Clatter.util.replyText(message, Clatter.currentUser)
      @open()

    openUserReply: (user) ->
      @setReplyTitle("@#{ user.screen_name }")
      @open()


    onOpenNewMessage: (event) -> @openNew()

    onOpenReplyUser: (event, user) ->
      @openUserReply(user)
      @$broadcast('modal-dialog.open-user-reply', event, user)

    onOpenReplyMessage: (event, message) ->
      @openMessageReply(message)
      @$broadcast('modal-dialog.open-message-reply', event, message)
