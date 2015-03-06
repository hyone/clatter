require 'rails_helper'
include ActionView::Helpers::DateHelper


describe 'Message Panel', type: :feature, js: true do
  let! (:user) { FactoryGirl.create(:user) }
  let! (:message) { FactoryGirl.create(:message, user: user, created_at: 2.hours.ago) }

  subject { page }

  before { visit user_path(user) }

  it { should have_link(message.user.name, user_path(message.user)) }
  it { should have_link("@#{message.user.screen_name}", user_path(message.user)) }
  it { should have_link("2 hours ago", user_path(message.user)) }

  context 'in message text' do
    let (:message_id) { "#message-#{message.id} .message-body" }
    it 'should contain message text' do
      should have_selector(message_id)
    end

    describe 'URL' do
      context 'with text includes URLs' do
        let (:url1) { URI('http://hoge.fuga.com/') }
        let (:url2) { URI('https://wwww.example.com/') }
        let! (:message) { FactoryGirl.create(:message, user: user, text: "hello #{url1} and #{url2}") }
        before { visit current_path }

        it 'should become a link' do
          [url1, url2].each do |url|
            should have_link("#{url.host}#{url.path}", href: "#{url}")
          end
        end
      end

      context 'with text includes long URL' do
        let (:url) { URI('https://wwww.example.com/hoge/fuga/foofoo.txt') }
        let! (:message) { FactoryGirl.create(:message, user: user, text: "hello #{url}") }
        before { visit current_path }

        it 'link text should be truncated' do
          should have_xpath("//a[contains(normalize-space(text()), '...')][@href='#{url}']")
        end
      end

      context 'with invalid URL' do
        let (:url) { 'www.example.com' }
        let! (:message) { FactoryGirl.create(:message, user: user, text: "hello #{url}") }
        before { visit current_path }

        it 'should not become link' do
          should_not have_xpath("//a[@href='#{url}']")
        end
      end

      context 'with other protocols than http (https)' do
        let (:url) { 'ssh://www.example.com/' }
        let! (:message) { FactoryGirl.create(:message, user: user, text: "hello #{url}") }
        before { visit current_path }

        it 'should not become link' do
          should_not have_xpath("//a[@href='#{url}']")
        end
      end
    end

    context 'with @screen_name' do
      let! (:reply) { FactoryGirl.create(:message_with_reply, user: user) }
      before { visit with_replies_user_path(user) }

      it "'@screen_name' is linked to that user page" do
        reply.users_replied_to.each do |u|
          expect(page).to have_link("#{u.screen_name}", user_path(u))
        end
      end

      context 'when @screen_name is not an existing user' do
        let! (:reply) { FactoryGirl.create(:message, user: user, text: '@no_such_user hello!') }
        before { visit current_path }

        it 'should not become link' do
          should_not have_link(message_id, reply.text)
        end
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
