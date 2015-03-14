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

    dateFromNow: ->
      d = moment(@message.created_at)
      """<span title="#{d.format('h:mm A - D MMM YYYY')}">#{d.fromNow()}</span>"""

    textHtml: ->
      Clatter.util.messageToHtml(@message, @keywords)

  methods:
    onClickReplyButton: (event) ->
      @$dispatch('message.on-click-reply-button', event, @message)
