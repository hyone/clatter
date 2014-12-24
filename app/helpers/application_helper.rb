module ApplicationHelper
  def page_title(text = nil)
    base = 'TwitterApp'
    return base if text.blank?
    [text, base].join(' | ')
  end

  def active?(url)
    request.path_info == url
  end
end
