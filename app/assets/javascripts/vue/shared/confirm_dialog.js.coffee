Clatter.ConfirmDialogComponent = Vue.extend
  template: '#confirm-dialog-template'
  replace: true

  paramAttributes: ['body-view']

  data: ->
    title: ''
    bodyView: undefined
    params: {}
    target: undefined

  components:
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

  created: ->
    @overrideRailsAjax()

  compiled: ->
    @setupEventListeners()

  methods:
    hide: ->
      $(@$el).modal('hide')

    open: ->
      $(@$el).modal('show')
      @$$.okButton.focus()

    toggle: ->
      $(@$el).modal('toggle')

    # override $.rails.allowAction
    overrideRailsAjax: ->
      @_allowActionOrig = $.rails.allowAction
      $.rails.allowAction = (link) =>
        unless link.attr('data-confirm')
          return true
        if link.attr('data-confirmed')
          link.attr('data-confirmed', null)
          return true
        @target = link
        @title  = @target.attr('data-confirm')
        if message = @target.closest('.message-data').data('message')
          @showMessage(message)
        @open()
        false

    setupEventListeners: ->
      $(@$el).on 'hidden.bs.modal', (event) =>
        @resetMessage()

    showMessage: (message) ->
      @params =
        message: message
        prefix: 'parent-message'
        showFoot: false
      @bodyView = 'message'

    resetMessage: (message) ->
      @bodyView = ''
      @params   = {}

    onClickOk: ->
      @target.attr('data-confirmed', true)
      @target.trigger('click.rails')
