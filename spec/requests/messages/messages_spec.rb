require 'rails_helper'


describe 'Messages page', type: :request do

  def post_message(m)
    post messages_path(format: 'json'), {
      message: { text: m.text }
    }
  end

  let (:user) { FactoryGirl.create(:user) }

  describe 'POST /messages' do
    let (:new_message) { FactoryGirl.build(:message) }

    context 'as guest' do
      it 'should respond with 401' do
        post_message(new_message)
        expect(status).to eq(401)
      end

      it 'should not create a message' do
        expect { post_message(new_message) }.not_to change(Message, :count)
      end
    end

    context 'as user' do
      before { signin user }

      it 'should create a message', js: true do
        expect { post_message(new_message) }.to change(Message, :count).by(1)
      end
    end
  end


  describe 'DELETE /messages' do
    let! (:message) { FactoryGirl.create(:message, user: user) }
    let  (:other_user) { FactoryGirl.create(:user) }

    def delete_message(m)
      delete message_path(message, format: 'json')
    end


    context 'as guest' do
      it 'should respond with 401' do
        delete_message(message)
        expect(status).to eq(401)
      end

      it 'should not delete a message' do
        expect { delete_message(message) }.not_to change(Message, :count)
      end
    end

    context 'as non owner' do
      before { signin other_user }

      it 'should respond with 401' do
        delete_message(message)
        expect(status).to eq(401)
      end

      it 'should not delete a message' do
        expect { delete_message(message) }.not_to change(Message, :count)
      end
    end

    context 'as owner' do
      before { signin user }

      it 'should delete a message' do
        expect { delete_message(message) }.to change(Message, :count).by(-1)
      end
    end
  end
end
