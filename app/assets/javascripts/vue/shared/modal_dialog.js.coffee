TwitterApp.ModalDialogComponent = Vue.extend
  template: '#modal-dialog-template'
  replace: true

  data: ->
    body: ''
    title: ''
    view: 'modal-message-form'

  components:
    'modal-message-form': TwitterApp.ModalMessageFormComponent

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
      @body = ''

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

    openMessageReply: (body, screen_name) ->
      @body = body
      @setReplyTitle(screen_name)
      @open()

    openUserReply: (screen_name) ->
      @setReplyTitle(screen_name)
      @open()


    onOpenNew: (event) -> @openNew()

    onOpenUserReply: (event, screen_name) ->
      @openUserReply(screen_name)
      @$broadcast('modal-dialog.open-user-reply', event, screen_name)

    onOpenMessageReply: (event, body, screen_name) ->
      @openMessageReply(body, screen_name)
      @$broadcast('modal-dialog.open-message-reply', event, body, screen_name)
