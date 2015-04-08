Clatter.MessageComponent = Vue.extend
  template: '#message-template'
  replace: true

  paramAttributes: [ 'data-prefix-id', 'data-show-foot', 'data-keywords', 'data-action']

  components:
    'favorite-button': Clatter.FavoriteButtonComponent
    'retweet-button': Clatter.RetweetButtonComponent
    'message-actions-button':  Clatter.MessageActionsButtonComponent

  data: ->
    message: undefined
    prefixId: 'message'
    keywords: undefined
    showFoot: true
    action: undefined

  computed:
    canReply: ->
      !!Clatter.currentUser

    canActions: ->
      Clatter.currentUser and Clatter.currentUser.id == @message.user.id

    date: ->
      d = moment(@message.created_at)
      d.format(I18n.t('vue.message.datetime_format'))

    dateFromNow: ->
      d = moment(@message.created_at)
      d.fromNow()

    textHtml: ->
      Clatter.util.messageToHtml(@message, @keywords)

    messageJSON: ->
      # cut some redundant fields
      JSON.stringify @message, (key, value) ->
        switch key
          when 'favorite_users', 'retweet_users', 'parents', 'replies', 'reply_users'
            undefined
          else
            value

  methods:
    onClickReplyButton: (event) ->
      @$dispatch('_message.click-reply-button', event, @message)

    onClick: (event) ->
      if @isClickable(event.target)
        return false

      switch @action
        when 'status'
          location.href = "/u/#{@message.user.screen_name}/status/#{@message.id}"
        else
          false

    isClickable: (elem) ->
      tagName = $(elem).get(0).tagName
      tagName is 'A' or \
      tagName is 'BUTTON' or \
      $(elem).closest('a').size() > 0 or \
      $(event.target).closest('button').size() > 0


