require 'rails_helper'

describe RelationshipsController, :type => :controller do
  let (:user) { FactoryGirl.create(:user) }
  let (:other_user) { FactoryGirl.create(:user) }

  describe '#create' do
    context 'as user' do
      before { signin user }

      it 'should create the Relationship object' do
        expect {
          xhr :post, :create, format: 'json', relationship: { followed_id: other_user.id }
        }.to change {
          Relationship.find_by(
            follower_id: user.id,
            followed_id: other_user.id
          )
        }.from(nil)
      end

      it 'should return http success' do
        xhr :post, :create, format: :json, relationship: { followed_id: other_user.id }
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe '#destroy' do
    let! (:relationship) {
      FactoryGirl.create(:relationship, follower: user, followed: other_user)
    }

    context 'as user' do
      before { signin user }

      it 'should destroy the Relationship object' do
        expect {
          xhr :delete, :destroy, format: :json, id: relationship.id
        }.to change {
          Relationship.find_by(
            follower_id: user.id,
            followed_id: other_user.id
          )
        }.to(nil)
      end

      it 'should return http success' do
        xhr :delete, :destroy, format: :json, id: relationship.id
        expect(response).to have_http_status(:success)
      end
    end
  end
end
