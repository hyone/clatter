require 'rails_helper'
include ApiHelpers


describe 'Favorites pages' do
  let! (:user) { FactoryGirl.create(:user) }
  let! (:message) { FactoryGirl.create(:message) }

  shared_examples 'json favorites stats' do
    it 'should include count of user favorites' do
      expect(json_response['results']['favorite']['user']['favorites_count']).to eq(user.favorites_count)
    end

    it 'should include count of message favorited' do
      expect(json_response['results']['favorite']['message']['favorited_count']).to eq(
        message.favorited_count
      )
    end
  end


  describe 'POST /favorites' do
    def xhr_post_favorites
      xhr :post, favorites_path(format: 'json'), favorite: { message_id: message.id }
    end

    context 'as guest' do
      it 'should respond with 401' do
        xhr_post_favorites
        expect(status).to eq(401)
      end
    end

    context 'as user' do
      before { signin user }


      context 'with valid parameters' do
        it 'should respond with 200' do
          xhr_post_favorites
          expect(status).to eq(200)
        end

        it 'should create Favorite record' do
          expect { xhr_post_favorites }.to change {
            Favorite.find_by(user: user, message: message)
          }.from(nil).to(be_a Favorite)
        end

        describe 'json response' do
          before { xhr_post_favorites }

          include_examples 'json success responsable'

          it 'should include id of favorite has created' do
            n = json_response['results']['favorite']['id']
            expect(Favorite.find_by(id: n)).not_to be_nil
          end

          include_examples 'json favorites stats'
        end
      end

      context 'with invalid parameters' do
        before { message.id = nil }

        it 'should respond with 500' do
          xhr_post_favorites
          expect(status).to eq(500)
        end

        it 'should not create Favorite record' do
          expect { xhr_post_favorites }.not_to change {
            Favorite.find_by(user: user, message: message)
          }.from(nil)
        end

        describe 'json response' do
          before { xhr_post_favorites }
          include_examples 'json error responsable'
        end
      end

    end
  end


  describe 'DELETE /favorites/:id' do
    let! (:favorite) { FactoryGirl.create(:favorite, user: user, message: message) }

    def xhr_delete_favorite(m)
      xhr :delete, favorite_path(m, format: 'json')
    end

    context 'as guest' do
      it 'should response with 401' do
        xhr_delete_favorite(favorite)
        expect(status).to eq(401)
      end
    end

    context 'as non owner' do
      let (:other_user) { FactoryGirl.create(:user) }
      before { signin other_user }
      it 'should response with 401' do
        xhr_delete_favorite(favorite)
        expect(status).to eq(401)
      end
    end

    context 'as owner' do
      before { signin user }

      context 'with valid parameters' do
        it 'should respond with 200' do
          xhr_delete_favorite(favorite)
          expect(status).to eq(200)
        end

        it 'should delete Favorite record' do
          expect { xhr_delete_favorite(favorite) }.to change {
            Favorite.exists?(favorite.id)
          }.from(true).to(false)
        end

        describe 'json response' do
          before { xhr_delete_favorite(favorite) }
          include_examples 'json success responsable'
          include_examples 'json favorites stats'
        end
      end

      context 'with non existential id' do
        before { favorite.id = 0 }

        it 'should respond with 404' do
          xhr_delete_favorite(favorite)
          expect(status).to eq(404)
        end

        it 'should not delete Favorite record' do
          expect { xhr_delete_favorite(favorite) }.not_to change(user.favorites, :count)
        end
      end
    end
  end
end
