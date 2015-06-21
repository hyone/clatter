MessageForm = Vue.extend
  props: [
    {
      name: 'parent'
      type: Object
    },
    {
      name: 'placeholder'
      type: String
    },
    {
      name: 'text'
      type: String
    },
    {
      name: 'text-init'
      type: String
    },
    {
      name: 'rows'
      type: Number
    },
    {
      name: 'display'
      type: String
    }
  ]

  data: ->
    textInit: ''
    text: ''
    parent: {}
    placeholder: ''
    rows: 3
    display: 'block'
    LIMIT: 140

  computed:
    countRest: ->
      @LIMIT - @text.length

    isInitText: ->
      Clatter.util.trim(@text) == Clatter.util.trim(@textInit)

    isPostable: ->
      cnt = @countRest
      !@isInitText and (0 <= cnt and cnt < @LIMIT)

    isNearLimit: ->
      @countRest < 10

  compiled: ->
    @setupAjaxEventListeners()
    @setupKeybinds()

  events:
    'message-form.focus': 'focus'
    'message-form.reset': 'reset'

  methods:
    setupAjaxEventListeners: ->
      $(@$el).on 'ajax:success', (event, data, status, xhr) =>
        if data.response.status is 'success'
          @$dispatch '_message.created', event, data.results.message
        else
          @$dispatch '_app.alert', event, data.response
        @clear()

      $(@$el).on 'ajax:error', (event, xhr, status, error) =>
        @$dispatch '_app.alert', event,
          status: status,
          message: "#{I18n.t('alert.failed_create_message')}: #{error}"

      $(@$el).on 'ajax:complete', (event, data, status, xhr) =>
        $(event.target).find('button[type="submit"]').removeAttr('disabled')
        false

      $(@$el).on 'ajax:before', (event, data, status, xhr) =>
        $(event.target).find('button[type="submit"]').attr('disabled', 'disabled')
        @$$.textarea.blur()

    setupKeybinds: ->
      $(@$el).keydown (event) =>
        # ctrl + enter (command + enter)
        if ((event.ctrlKey and !event.metaKey) or (!event.ctrlKey and event.metaKey)) and \
          event.keyCode == 13
            $(@$el).find('button[type=submit]').click()

    focus: ->
      @$$.textarea.focus()

    reset: ->
      @textInit = @text = ''

    clear: ->
      @text = ''

    restoreText: ->
      @text or= @textInit

    onFocus: ->
      @restoreText()

    onBlur: ->
      @clear() if @isInitText


Clatter.ContentMainMessageFormComponent = MessageForm.extend
  template: '#content-main-message-form-template'
  replace: true

  created: ->
    @close()

  events:
    'message-panel.click-reply-button': 'onClickReplyButton'
    'message.created': 'onMessageCreated'

  computed:
    isOpen:
      @display == 'block'

  methods:
    open: ->
      @rows = 3
      @display = 'block'

    close: ->
      @rows = 1
      @display = 'none'

    onFocus: ->
      @restoreText()
      @open()

    onBlur: ->
      @clear() if @isInitText
      if @countRest == 140
        @close()

    onClickReplyButton: ->
      @open()
      @focus()

    onMessageCreated: ->
      @close()


Clatter.ModalMessageFormComponent = MessageForm.extend
  template: '#modal-message-form-template'
  replace: true

  events:
    'modal-dialog.open-message-reply': 'onOpenMessageReply'
    'modal-dialog.open-user-reply': 'onOpenUserReply'

  methods:
    onOpenMessageReply: (event, message) ->
      @textInit = @text = "#{ Clatter.util.replyText(message, Clatter.currentUser) } "
      @parent = message

    onOpenUserReply: (event, user) ->
      @textInit = @text = "@#{user.screen_name} "
