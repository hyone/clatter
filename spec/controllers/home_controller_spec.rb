require 'rails_helper'


describe HomeController, :type => :controller do
  describe "GET index" do
    it "returns http success" do
      signin nil
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET about" do
    it "returns http success" do
      get :about
      expect(response).to have_http_status(:success)
    end
  end
end
