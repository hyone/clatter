module ApplicationHelper
  def title(text = nil)
    base = 'TwitterApp'
    return base if text.blank?
    [text, base].join(' | ')
  end
end
