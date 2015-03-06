require 'rails_helper'


describe MessagesHelper, type: :helper do

  def link_regexp(user)
    %r|<a.*?href=(['"])#{user_path(user)}\1.*?>.*?@.*?#{user.screen_name}.*?</a>|
  end

  describe '#replace_reply_at_to_user_link' do
    subject { replace_reply_at_to_user_link(message) }

    context 'with non reply message' do
      let (:message) { FactoryGirl.create(:message) }
      it 'should do nothing' do
        expect(subject).to eq(message.text)
      end
    end

    context 'with a reply message' do
      let (:user) { FactoryGirl.create(:user) }
      let (:message) {
        FactoryGirl.create(:message_with_reply, users_replied_to: [user])
      }
      let! (:original_text) { message.text.clone() }

      it 'should replace "@user" text with a link to the user' do
        expect(subject).to match link_regexp(user)
      end

      specify 'should not affect the original text of the message' do
        subject
        expect(message.text).to eq(original_text)
      end
    end

    context 'with a multiple replies message' do
      let (:users) { 3.times.map do FactoryGirl.create(:user) end }
      let (:message) {
        FactoryGirl.create(:message_with_reply, users_replied_to: users)
      }
      it 'should replace every "@user" text with a link to that user respectively' do
        users.each do |user|
          expect(subject).to match link_regexp(user)
        end
      end
    end
  end

  describe '#replace_url_to_link' do
    subject { replace_url_to_link(text) }

    context 'with text including urls' do
      let (:url1) { URI('http://hoge.fuga.com/') }
      let (:url2) { URI('https://wwww.example.com/') }
      let (:text) { "hello #{url1} and #{url2}" }

      it 'should replace each URL to a link' do
        [url1, url2].each do |u|
          expect(subject).to include(%Q|<a href="#{u}">#{u.host}#{u.path}</a>|)
        end
      end
    end

    context 'with long URL' do
      let (:url1) { URI('https://wwww.example.com/hoge/fuga/foofoo.txt') }
      let (:text) { "hello #{url1}" }
     
      it 'should truncate link text' do
        expect(subject).to match(%Q|<a href="#{url1}">[^<]*\.\.\.</a>|)
      end
    end

    context 'with invalid URL' do
      let (:url) { 'www.example.com' }
      let (:text) { "hello #{url}" }

      it 'should not replace URL to link' do
        expect(subject).to eq(text)
      end
    end

    context 'with other protocols than http (https)' do
      let (:url) { 'ssh://www.example.com/' }
      let (:text) { "hello #{url}" }

      it 'should not replace URL to link' do
        expect(subject).to eq(text)
      end
    end
  end

  describe '#message_to_html' do
    let (:message) { FactoryGirl.create(:message) }

    it 'should call :replace_reply_at_to_user_link and :replace_url_to_link' do
      [:replace_reply_at_to_user_link, :replace_url_to_link].each do |method|
        expect(self).to receive(method)
      end
      message_to_html(message)
    end
  end
end
