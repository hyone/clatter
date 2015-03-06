TwitterApp.util =
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
