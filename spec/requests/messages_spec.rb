require 'rails_helper'
include ApiHelpers


describe 'Messages page', type: :request do
  let (:user) { FactoryGirl.create(:user) }

  describe 'POST /messages' do
    def xhr_post_messages
      xhr :post, messages_path(format: 'json'), message: { text: message.text }
    end

    let (:message) { FactoryGirl.build(:message) }

    context 'as guest' do
      it 'should respond with 401' do
        xhr_post_messages
        expect(status).to eq(401)
      end

      it 'should not create Message record' do
        expect { xhr_post_messages }.not_to change(Message, :count)
      end
    end

    context 'as user' do
      before { signin user }

      context 'with valid parameters' do
        it 'should respond with 200' do
          xhr_post_messages
          expect(status).to eq(200)
        end

        it 'should create Message record' do
          expect { xhr_post_messages }.to change(user.messages, :count).by(1)
        end

        describe 'json response' do
          before { xhr_post_messages }
          include_examples 'json success responsable'

          it 'should include id of new message' do
            expect(json_response['results']['message']['id']).not_to be_nil
          end
        end
      end

      context 'with invalid parameters' do
        before { message.text = nil }

        it 'should respond with 500' do
          xhr_post_messages
          expect(status).to eq(500)
        end

        it 'should not create Message record' do
          expect { xhr_post_messages }.not_to change(user.messages, :count)
        end

        describe 'json response' do
          before { xhr_post_messages }
          include_examples 'json error responsable'
        end
      end
    end
  end


  describe 'DELETE /messages' do
    let! (:message) { FactoryGirl.create(:message, user: user) }
    let  (:other_user) { FactoryGirl.create(:user) }

    def xhr_delete_message(m)
      xhr :delete, message_path(message, format: 'json')
    end


    context 'as guest' do
      it 'should respond with 401' do
        xhr_delete_message(message)
        expect(status).to eq(401)
      end

      it 'should not delete Message record' do
        expect { xhr_delete_message(message) }.not_to change(Message, :count)
      end
    end

    context 'as non owner' do
      before { signin other_user }

      it 'should respond with 401' do
        xhr_delete_message(message)
        expect(status).to eq(401)
      end

      it 'should not delete Message record' do
        expect { xhr_delete_message(message) }.not_to change(Message, :count)
      end
    end

    context 'as owner' do
      before { signin user }

      context 'with valid parameters' do
        it 'should respond with 200' do
          xhr_delete_message(message)
          expect(status).to eq(200)
        end

        it 'should delete Message record' do
          expect { xhr_delete_message(message) }.to change(Message, :count).by(-1)
        end

        describe 'json response' do
          before { xhr_delete_message(message) }
          include_examples 'json success responsable'
        end
      end

      context 'with non existential id' do
        before { message.id = 0 }

        it 'should respond with 404' do
          xhr_delete_message(message)
          expect(status).to eq(404)
        end

        it 'should not delete Message record' do
          expect { xhr_delete_message(message) }.not_to change(Message, :count)
        end
      end
    end
  end
end
