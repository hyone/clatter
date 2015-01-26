require 'rails_helper'


describe 'Messages page', type: :request do
  subject { page }
  let (:user) { FactoryGirl.create(:user) }

  describe 'POST /messages' do
    let (:new_message) { FactoryGirl.build(:message) }

    context 'as guest' do
      it 'should not create a message' do
        expect { post_message(new_message) }.not_to change(Message, :count)
      end

      it 'should redirect_to signin page' do
        post_message(new_message)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'as user' do
      before { signin user }

      it 'should create a message' do
        expect { post_message(new_message) }.to change(Message, :count).by(1)
      end

      it 'should redirect_to root_path' do
        post_message(new_message)
        expect(response).to redirect_to(root_path)
      end
    end
  end


  describe 'DELETE /messages' do
    let! (:message) { FactoryGirl.create(:message, user: user) }
    let  (:other_user) { FactoryGirl.create(:user) }

    context 'as guest' do
      it 'should not delete a message' do
        expect { delete message_path(message) }.not_to change(Message, :count)
      end

      it 'should redirect_to signin page' do
        delete message_path(message)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'as non owner' do
      before { signin other_user }

      it 'should not delete a message' do
        expect { delete message_path(message) }.not_to change(Message, :count)
      end

      it 'should redirect_to signin page' do
        delete message_path(message)
        expect(response).to redirect_to(root_path)
      end
    end

    context 'as owner' do
      before { signin user }

      it 'should delete a message' do
        expect { delete message_path(message) }.to change(Message, :count).by(-1)
      end

      it 'should redirect_to root_path' do
        delete message_path(message)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
