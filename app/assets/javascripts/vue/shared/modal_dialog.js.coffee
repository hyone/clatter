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

    setReplyTitle: (screen_name) ->
      @title = I18n.t('views.modal_dialog.reply_to', name: screen_name)

    setupModalEventListeners: ->
      $(@$el).on 'hidden.bs.modal', (event) =>
        @clearBody()
        @$broadcast 'message-form.clear', event

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
      @setReplyTitle(message.user.screen_name)
      @open()

    openUserReply: (screen_name) ->
      @setReplyTitle(screen_name)
      @open()


    onOpenNew: (event) -> @openNew()

    onOpenUserReply: (event, screen_name) ->
      @openUserReply(screen_name)
      @$broadcast('modal-dialog.open-user-reply', event, screen_name)

    onOpenMessageReply: (event, message) ->
      @openMessageReply(message)
      @$broadcast('modal-dialog.open-message-reply', event, message)
