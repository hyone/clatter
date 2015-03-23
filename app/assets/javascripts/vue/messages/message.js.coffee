Clatter.MessageComponent = Vue.extend
  template: '#message-template'
  replace: true

  paramAttributes: ['show-foot', 'prefix', 'keywords']

  components:
    'favorite-button': Clatter.FavoriteButtonComponent
    'retweet-button': Clatter.RetweetButtonComponent
    'message-actions-button':  Clatter.MessageActionsButtonComponent

  data: ->
    message: undefined
    keywords: undefined
    showFoot: true
    prefix: 'message'

  computed:
    canReply: ->
      !!Clatter.currentUser

    canActions: ->
      Clatter.currentUser and Clatter.currentUser.id == @message.user.id

    date: ->
      d = moment(@message.created_at)
      d.format('h:mm A - D MMM YYYY')

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
