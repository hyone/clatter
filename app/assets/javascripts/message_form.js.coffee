MessageForm = Vue.extend
  data: ->
    text: ''
    rows: 3
    display: 'block'
    LIMIT: 140

  computed:
    countRest: ->
      @LIMIT - @text.length

    isPostable: ->
      cnt = @countRest
      0 <= cnt and cnt < @LIMIT

    isNearLimit: ->
      @countRest < 10

  methods:
    onBlur: ->
    onFocus: ->


ContentMainMessageForm = MessageForm.extend
  template: '#content-main-message-form-component-template'

  created: ->
    @close()

  methods:
    open: ->
      @rows = 3
      @display = 'block'

    close: ->
      @rows = 1
      @display = 'none'

    onBlur: ->
      if @countRest == 140
        @close()

    onFocus: ->
      @open()


ModalMessageForm = MessageForm.extend
  template: '#modal-message-form-component-template'

  created: ->
    @$on 'modal-dialog.open-message-reply', @onOpenMessageReply
    @$on 'modal-dialog.open-user-reply', @onOpenUserReply

  methods:
    setReplyText: (screen_name) ->
      @text = "@#{screen_name} "

    onOpenMessageReply: (event, parent, screen_name) ->
      @setReplyText(screen_name)
      # $(@$el).find('#modal-message-form-text')[0].focus()

    onOpenUserReply: (event, screen_name) ->
      @setReplyText(screen_name)


Vue.component('content-main-message-form', ContentMainMessageForm)
Vue.component('modal-message-form', ModalMessageForm)
