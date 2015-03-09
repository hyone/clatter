TwitterApp.MessageComponent = Vue.extend
  template: '#message-template'
  replace: true

  paramAttributes: ['show-foot', 'prefix', 'keywords']

  components:
    'favorite-button': TwitterApp.FavoriteButtonComponent
    'retweet-button':  TwitterApp.RetweetButtonComponent

  data: ->
    message: undefined
    keywords: undefined
    showFoot: true
    prefix: 'message'

  computed:
    canActions: ->
      !!TwitterApp.currentUser

    dateFromNow: ->
      d = moment(@message.created_at)
      """<span title="#{d.format('h:mm A - D MMM YYYY')}">#{d.fromNow()}</span>"""

    textHtml: ->
      @messageToHtml(@message.text)

  compiled: ->
    @setupAjaxEventListeners()

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

    messageToHtml: (text) ->
      ret = TwitterApp.util.urlToLink(text)
      ret = TwitterApp.util.atReplyToLink(ret, @message.reply_users)
      if @keywords
        for keyword in @keywords
          ret = TwitterApp.util.keywordToBold(ret, keyword)
      ret

    onClickReplyButton: (event) ->
      @$dispatch('message.on-click-reply-button', event, @message)
