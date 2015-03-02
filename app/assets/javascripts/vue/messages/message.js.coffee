TwitterApp.MessageComponent = Vue.extend
  template: '#message-template'
  replace: true

  paramAttributes: ['show-foot', 'prefix']

  components:
    'favorite-button': TwitterApp.FavoriteButtonComponent
    'retweet-button':  TwitterApp.RetweetButtonComponent

  data: ->
    message: undefined
    showFoot: true
    prefix: 'message'

  computed:
    canActions: ->
      !!TwitterApp.currentUser

  compiled: ->
    @setupAjaxEventListeners()
    # @$log 'message'

  methods:
    setupAjaxEventListeners: ->
      $(@$el).on 'ajax:success', (event, data, status, xhr) =>
        if data.response.status isnt 'success'
          @$dispatch 'app.alert', event, data.response
          return

        t = $(event.target)
        if t.hasClass('delete-message')
          @$dispatch('message.deleted', event, @message)

      $(@$el).on 'ajax:error', (event, xhr, status, error) =>
        @$dispatch 'app.alert', event,
          status: status,
          message: "#{I18n.t('views.alert.failed_delete_message')}: #{error}"

    onClickReplyButton: (event) ->
      @$dispatch('message.on-click-reply-button', event, @message)
