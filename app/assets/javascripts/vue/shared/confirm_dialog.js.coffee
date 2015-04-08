Clatter.ConfirmDialogComponent = Vue.extend
  template: '#confirm-dialog-template'
  replace: true

  paramAttributes: ['data-body-view']

  data: ->
    title: ''
    bodyView: undefined
    params: {}
    target: undefined
    size: 'normal'

  computed:
    dialogSizeClass: ->
      switch (@size)
        when 'small' then 'modal-sm'
        when 'large' then 'modal-lg'
        else              ''

  components:
    message:
      template: """
        <div v-component="inner"
             v-with="
              message:  params.message,
              prefixId: params.prefixId,
              showFoot: params.showFoot
            ">
        </div>
      """
      components:
        inner: Clatter.MessageComponent
    default:
      template: """
        <div class="confirmation-dialog-description">{{params.description}}</div>
      """

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
        if message = @target.closest('.message-data').data('message')
          @title = @target.attr('data-confirm')
          @showMessageView(message)
        else
          @title = I18n.t('vue.modal_dialog.confirmation_default_title')
          @showDefaultView(@target.attr('data-confirm'))
        @open()
        false

    setupEventListeners: ->
      $(@$el).on 'hidden.bs.modal', (event) =>
        @resetMessage()

    showDefaultView: (description) ->
      @size = 'small'
      @params =
        description: description
      @bodyView = 'default'

    showMessageView: (message) ->
      @size = 'normal'
      @params =
        message: message
        prefixId: 'parent-message'
        showFoot: false
      @bodyView = 'message'

    resetMessage: (message) ->
      @bodyView = ''
      @params   = {}

    onClickOk: ->
      @target.attr('data-confirmed', true)
      @target.trigger('click.rails')
