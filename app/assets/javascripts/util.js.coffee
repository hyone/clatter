class Clatter.util
  @uri: (url) ->
    elem = document.createElement('a')
    elem.href = url
    elem

  # from: https://github.com/epeli/underscore.string/blob/master/truncate.js
  @truncate: (str, length, postfix) ->
    postfix = postfix || '...'
    length  = ~~length
    if str.length > length
      str.slice(0, length) + postfix
    else
      str

  @trim: (str) ->
    str.replace /(^\s+)|(\s+$)/g, ""

  @users_reply_to: (message, currentUser = null) ->
    r = _.chain message.reply_users
         .union [message.user]
         .filter (m) -> m.id isnt currentUser?.id
         .value()
    if r.length > 0 then r else [message.user]

  @replyText: (message, currentUser = null) ->
    _.chain @users_reply_to(message, currentUser)
     .pluck 'screen_name'
     .map (s) -> "@#{s}"
     .join ' '

  @keywordToBold: (text, keyword = null) ->
    return text unless keyword
    m = findAndReplaceDOMText $("<div>#{text}</div>").get(0),
      find: new RegExp(keyword, 'gi')
      wrap: 'strong'
    m.node.innerHTML

  @URI_REGEXP:
    /https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b(?:[-a-zA-Z0-9@:%_\+.~#?&//=]*)/g

  @urlToLink: (text) ->
    text.replace @URI_REGEXP, (m) =>
      url  = @uri(m)
      text = "#{url.hostname}#{if url.pathname is '/' then '' else url.pathname }"
      "<a href='#{url}' title='#{url}'>#{ @truncate(text, 25) }</a>"

  @atReplyToLink: (text, users) ->
    _.reduce users, (acc, user) =>
      atName = "@#{user.screen_name}"
      acc.replace new RegExp("#{atName}\\b", 'g'), (m) ->
        "<a href='/u/#{user.screen_name}'>#{atName}</a>"
    , text

  @messageToHtml: (message, keywords = []) =>
    ret = @urlToLink(message.text)
    ret = @atReplyToLink(ret, message.reply_users)
    _.reduce keywords, (acc, keyword) =>
      @keywordToBold(acc, keyword)
    , ret
