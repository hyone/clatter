Clatter.MessagePanelComponent = Vue.extend
  template: '#message-panel-template'

  components:
    'content-main-message-form': Clatter.ContentMainMessageFormComponent
    'favorite-button': Clatter.FavoriteButtonComponent
    'retweet-button': Clatter.RetweetButtonComponent
    'message-actions-button':  Clatter.MessageActionsButtonComponent
    'follow-button': Clatter.FollowButtonComponent
    'user-actions-button': Clatter.UserActionsButtonComponent

  events:
    'message.created': 'onMessageCreated'
    'message.deleted': 'onMessageDeleted'

  data: ->
    prefix: 'message'
    message: {}

  computed:
    isOwner: ->
      Clatter.currentUser and Clatter.currentUser.id == @message.user.id

    isLogedIn: ->
      !!Clatter.currentUser

    canReply: -> @isLogedIn
    canActions: -> @isOwner

    hasFavorites: -> @message.favorited_count > 0
    hasRetweets:  -> @message.retweeted_count > 0
    hasParents:   -> @message.parents.length  > 0
    hasReplies:   -> @message.replies.length  > 0
    hasAvators:   -> @avators.length > 0

    avators: ->
      _.chain @message.favorite_users
       .union @message.retweet_users
       .sortBy (m) -> m.created_at
       .take(10)
       .value()

    date: ->
      d = moment(@message.created_at)
      """#{d.format('h:mm A - D MMM YYYY')}"""

    formText: ->
      "#{ Clatter.util.replyText(@message, Clatter.currentUser) } "
    formPlaceholder: ->
      "Reply to #{ Clatter.util.replyText(@message, Clatter.currentUser) }"

    textHtml: ->
      Clatter.util.messageToHtml(@message, @keywords)

  methods:
    onClickReplyButton: (event) ->
      @$broadcast('message.on-click-reply-button', event, @message)

    onMessageCreated: (event, message) ->
      @message.replies.push(message)

    onMessageDeleted: (event, message) ->
      switch message.id
        when @message.id
          location.href = "/"
        else
          @message.parents.$remove(message)
          @message.replies.$remove(message)