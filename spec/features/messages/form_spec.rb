require 'rails_helper'

describe 'Message Form', type: :feature, js: true do
  subject { page }

  context 'as user' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      signin user
      visit root_path
    end

    context 'when creating new message' do
      include_examples 'a new postable form', :foldable do
        let(:prefix) { 'content-main' }
      end
    end

    context 'when replying message' do
      let!(:message) { FactoryGirl.create(:message) }
      before { visit status_user_path(message.user, message.id) }

      include_examples 'a replyable form', :foldable do
        let(:prefix) { 'content-main' }
      end
    end

    context 'when replying multi users' do
      let!(:message) { FactoryGirl.create(:message) }
      let!(:reply) do
        FactoryGirl.create(
          :message_with_reply,
          users_replied_to: [message.user, user],
          message_id_replied_to: message.id
        )
      end
      before { visit status_user_path(reply.user, reply.id) }

      include_examples 'a multi replyable form', :foldable do
        let(:prefix) { 'content-main' }
      end
    end
  end
end
