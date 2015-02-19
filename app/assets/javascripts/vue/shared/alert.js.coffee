window.TwitterApp.AlertComponent = Vue.extend
  template: '#alert-template'

  replace: true

  paramAttributes: ['status', 'message']

  data: ->
    status: undefined
    message: undefined
    details: []

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
      # Reseting 'details' property causes a trouble that this vm itself has been deleted (bug?)
      # # @alert.details = undefined

    onClickCloseButton: ->
      @close()
