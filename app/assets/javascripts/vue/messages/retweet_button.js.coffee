TwitterApp.RetweetButtonComponent = Vue.extend
  template: '#retweet-button-template'
  replace: true

  data: ->
    message: undefined

  computed:
    isRetweeted: ->
      !!@message.retweeted?.id
    hasRetweets: ->
      @message.retweeted_count > 0
    canRetweet: ->
      @message.permissions.retweet

  compiled: ->
    @setupAjaxEventListeners()

  ready: ->
    # @$log @message.retweeted

  methods:
    setupAjaxEventListeners: ->
      $(@$el).on 'ajax:success', (event, data, status, xhr) =>
        unless data.response.status == 'success'
          @$dispatch 'app.alert', event, data.response
          return false
        json = data.results.retweet
        @updateButtonStatus(json)
        false

      $(@$el).on 'ajax:complete', (event, data, status, xhr) =>
        $(event.target).find('button[type="submit"]').removeAttr('disabled')
        false

      $(@$el).on 'ajax:before', (event, data, status, xhr) =>
        $(event.target).find('button[type="submit"]').attr('disabled', 'disabled')

      $(@$el).on 'ajax:error', (event, xhr, status, error) =>
        @$dispatch 'app.alert', event,
          status: status,
          message: "#{I18n.t('views.alert.failed_retweet_message')}: #{error}"
        false

    updateButtonStatus: (data) ->
       @message.retweeted.id    = data.message.retweeted.id
       @message.retweeted_count = data.message.retweeted_count
