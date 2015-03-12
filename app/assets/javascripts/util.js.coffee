Clatter.util =
  uri: (url) ->
    elem = document.createElement('a')
    elem.href = url
    elem

  # from: https://github.com/epeli/underscore.string/blob/master/truncate.js
  truncate: (str, length, truncateStr) ->
    truncateStr = truncateStr || '...'
    length = ~~length
    if str.length > length
      str.slice(0, length) + truncateStr
    else
      str

  keywordToBold: (text, keyword = null) ->
    return text unless keyword
    text.replace new RegExp(keyword, 'gi'), (m) -> "<strong>#{m}</strong>"

  URI_REGEXP:
    /https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b(?:[-a-zA-Z0-9@:%_\+.~#?&//=]*)/g

  urlToLink: (text) ->
    text.replace Clatter.util.URI_REGEXP, (m) ->
      url  = Clatter.util.uri(m)
      text = "#{url.hostname}#{if url.pathname is '/' then '' else url.pathname }"
      "<a href='#{url}' title='#{url}'>#{ Clatter.util.truncate(text, 25) }</a>"

  atReplyToLink: (text, users) ->
    for user in users
      atName = "@#{user.screen_name}"
      text = text.replace new RegExp("#{atName}\\b", 'g'), (m) ->
        "<a href='/u/#{user.screen_name}'>#{atName}</a>"
    text
