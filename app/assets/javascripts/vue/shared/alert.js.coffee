window.Clatter.AlertComponent = Vue.extend
  template: '#alert-template'

  replace: true

  paramAttributes: ['data-status', 'data-message']

  data: ->
    status: undefined
    message: undefined
    details: []

  events:
    'app.alert': 'onAlert'

  computed:
    hasMessage: -> !!@status and !!@message
    hasDetails: -> @details?.length > 0

    className: ->
      switch @status
        when 'notice'         then 'success'
        when 'alert', 'error' then 'danger'
        else @status

  watch:
    'hasMessage': (value, oldValue) ->
      if value and @className == 'success'
        setTimeout =>
          @close()
        , 5000

  methods:
    show: (status, message, details) ->
      @status  = status
      @message = message
      @details = details

    close: ->
      @status  = undefined
      @message = undefined
      # XXX: Reseting 'details' property causes a trouble that this vm itself has been deleted (bug?)
      # # @details = undefined

    onClickCloseButton: ->
      @close()

    onAlert: (event, data) ->
      @show(data.status, data.message, data.details)
