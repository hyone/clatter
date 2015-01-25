Vue.directive 'modal-dialog',
  bind: (value) ->
    for name in ['show', 'shown', 'hide', 'hidden', 'loaded']
      do =>
        event_name = "#{name}.bs.modal"
        $(@el).on event_name, (event) =>
          @vm.$emit event_name, event


ModalDialog = Vue.extend
  template: '#modal-dialog-template'
  data: ->
    body: ''
    title: ''

  created: ->
    @$on 'modal-dialog.open-new', @onOpenNew
    @$on 'modal-dialog.open-message-reply', @onOpenMessageReply
    @$on 'modal-dialog.open-user-reply', @onOpenUserReply
    @$on 'hidden.bs.modal', ->
      @clearBody()

  methods:
    clearBody: ->
      @body = ''

    setDefaultTitle: ->
      @title = I18n.t('views.modal_dialog.compose_new_message')

    setReplyTitle: (screen_name) ->
      @title = I18n.t('views.modal_dialog.reply_to', name: screen_name)

    onOpenNew: (event) ->
      @setDefaultTitle()

    onOpenMessageReply: (event, body, screen_name) ->
      @body = body
      @setReplyTitle(screen_name)

    onOpenUserReply: (event, screen_name) ->
      @setReplyTitle(screen_name)

Vue.component('modal-dialog', ModalDialog)
