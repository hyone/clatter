module ApplicationHelper
  def page_title(text = nil)
    base = 'TwitterApp'
    return base if text.blank?
    [text, base].join(' | ')
  end


  # From https://github.com/tnantoka/miclo/

  def decode_bindings(encoded)
    space = '(\+|%20)'
    encoded
      .gsub(/%7B%7B#{space}*/i, '{{').gsub(/#{space}*%7D%7D/i, '}}') # delimiters
      .gsub(/#{space}%7C#{space}/i, ' | ') # filter
      .gsub(/\+%2B\+/i, ' + ') # expression
  end

  def bindable_path(path, *args)
    decode_bindings(send("#{path}_path", *args))
  end
end
