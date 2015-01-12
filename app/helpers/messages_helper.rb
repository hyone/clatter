module MessagesHelper
  def replace_reply_at_to_user_link(message)
    text = message.text
    message.users_replied_to.each do |u|
      link = link_to u, class: 'at-reply-link' do
        content_tag('span', '@', class: 'at-mark') +
        content_tag('span', u.screen_name, class: 'at-reply-screen-name')
      end
      text.gsub! /@#{u.screen_name}/, link 
    end
    text
  end
end
