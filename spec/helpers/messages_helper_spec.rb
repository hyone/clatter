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
end
