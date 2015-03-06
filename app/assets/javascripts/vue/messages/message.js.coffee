URI_REGEXP = /https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b(?:[-a-zA-Z0-9@:%_\+.~#?&//=]*)/g


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
      ret = @makeUrlToLink(text)
      ret = @makeAtReplyToLink(ret)
      ret

    makeUrlToLink: (text) ->
      text.replace URI_REGEXP, (m) ->
        url  = TwitterApp.util.uri(m)
        text = "#{url.hostname}#{if url.pathname is '/' then '' else url.pathname }"
        "<a href='#{url}' title='#{url}'>#{ TwitterApp.util.truncate(text, 25) }</a>"

    makeAtReplyToLink: (text) ->
      for user in @message.reply_users
        atName = "@#{user.screen_name}"
        text = text.replace new RegExp("#{atName}\\b", 'g'), (m) ->
          "<a href='/u/#{user.screen_name}'>#{atName}</a>"
      text


    onClickReplyButton: (event) ->
      @$dispatch('message.on-click-reply-button', event, @message)
