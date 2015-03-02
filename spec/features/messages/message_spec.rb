require 'rails_helper'
include ActionView::Helpers::DateHelper
include MessagesHelper


describe 'Message Panel', type: :feature, js: true do
  let! (:user) { FactoryGirl.create(:user) }
  let! (:message) { FactoryGirl.create(:message, user: user) }

  subject { page }

  before { visit user_path(user) }

  it { should have_link(message.user.name, user_path(message.user)) }
  it { should have_link("@#{message.user.screen_name}", user_path(message.user)) }
  it { should have_link(time_ago_in_words(message.created_at), user_path(message.user)) }

  it 'should contain message text' do
    expect(page).to have_selector(
      "#message-#{message.id} .message-body",
      replace_reply_at_to_user_link(message)
    )
  end

  context 'when reply' do
    let! (:reply) { FactoryGirl.create(:message_with_reply, user: user) }
    before { visit with_replies_user_path(user) }

    it "'@screen_name' words in text is linked to that user page" do
      reply.users_replied_to.each do |u|
        expect(page).to have_link("#{u.screen_name}", user_path(u))
      end
    end
  end

  context 'when retweeted message' do
    let! (:retweet) { FactoryGirl.create(:retweet, user: user) }
    before { visit current_path }

    it 'should display retweet context message' do
      expect(page).to have_selector('.message-context', I18n.t('views.message_panel.retweeted'))
      expect(page).to have_selector('.message-context', retweet.user.screen_name)
    end
  end
end
