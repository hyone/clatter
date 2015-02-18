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

  compiled: ->
    @setupAjaxEventListeners()
    @setupKeybinds()

  events:
    'message-form.focus': 'focus'
    'message-form.clear': 'clear'

  methods:
    setupAjaxEventListeners: ->
      $(@$el).on 'ajax:success', (event, data, status, xhr) =>
        if data.response.status is 'success'
          @$dispatch 'message.created', event, data.results.message
        else
          @$dispatch 'app.alert', event, data.response
        @clear()

      $(@$el).on 'ajax:error', (event, xhr, status, error) =>
        @$dispatch 'app.alert', event,
          status: status,
          message: "#{I18n.t('views.alert.failed_create_message')}: #{error}"

    setupKeybinds: ->
      $(@$el).keydown (event) =>
        # ctrl + enter (command + enter)
        if ((event.ctrlKey and !event.metaKey) or (!event.ctrlKey and event.metaKey)) and \
          event.keyCode == 13
            $(@$el).find('button[type=submit]').click()

    focus: ->
      @$$.textarea.focus()

    clear: ->
      @text = ''


TwitterApp.ContentMainMessageFormComponent = MessageForm.extend
  template: '#content-main-message-form-template'
  replace: true

  created: ->
    @close()

  events:
    'content-main-message-form:close': 'close'

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


TwitterApp.ModalMessageFormComponent = MessageForm.extend
  template: '#modal-message-form-template'
  replace: true

  events:
    'modal-dialog.open-message-reply': 'onOpenMessageReply'
    'modal-dialog.open-user-reply': 'onOpenUserReply'

  methods:
    setReplyText: (screen_name) ->
      @text = "@#{screen_name} "

    onBlur: ->
    onFocus: ->

    onOpenMessageReply: (event, message) ->
      @setReplyText(message.user.screen_name)

    onOpenUserReply: (event, screen_name) ->
      @setReplyText(screen_name)
