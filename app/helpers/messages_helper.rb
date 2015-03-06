require 'uri'

module MessagesHelper
  def replace_reply_at_to_user_link(message)
    text = message.text.clone
    message.users_replied_to.each do |u|
      link = link_to u, class: 'at-reply-link' do
        content_tag('span', '@', class: 'at-mark') +
        content_tag('span', u.screen_name, class: 'at-reply-screen-name')
      end
      text.gsub! /@#{u.screen_name}/, link 
    end
    text
  end

  def replace_url_to_link(text)
    text.gsub URI.regexp(["http", "https"]) do |m|
      u = URI(m)
      link_to truncate("#{u.host}#{u.path}", length: 25, separator: '...'), m
    end
  end

  def message_to_html(message)
    text = replace_reply_at_to_user_link(message)
    text = replace_url_to_link(text)
    text
  end
end
