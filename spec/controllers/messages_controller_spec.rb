require 'rails_helper'

describe MessagesController, :type => :controller do
  let (:valid_session) { {} }

  describe 'GET create' do
    it 'returns http success' do
      signin nil
      get :create
      expect(response).to have_http_status(:redirect)
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
