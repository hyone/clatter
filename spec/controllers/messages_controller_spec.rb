require 'rails_helper'

describe MessagesController, :type => :controller do
  let (:user) { FactoryGirl.create(:user) }
  let (:valid_session) { {} }

  render_views

  describe 'GET create' do
    it 'returns http success' do
      signin nil
      get :create
      expect(response).to have_http_status(:redirect)
    end
  end

  describe '#create' do
    context 'when format is json' do
      context 'as user' do
        before { signin user }

        it 'should return http success' do
          xhr :post, :create, format: 'json', message: { text: 'hello world', user_id: user.id }
          expect(response).to have_http_status(:success)
        end

        it 'should create the Message object' do
          expect {
            xhr :post, :create, format: 'json', message: { text: 'hello world', user_id: user.id }
          }.to change(Message, :count).by(1)
        end
      end
    end
  end

  describe 'GET destroy' do
    it 'returns http success' do
      user = FactoryGirl.create(:user)
      signin nil
      delete :destroy, {id: user.to_param}, valid_session
      expect(response).to have_http_status(:redirect)
    end
  end

end
