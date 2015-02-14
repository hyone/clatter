require 'rails_helper'
include ApiHelpers


describe 'Favorites pages' do
  let! (:user) { FactoryGirl.create(:user) }
  let! (:message) { FactoryGirl.create(:message) }

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

      it 'should respond with 200' do
        xhr_post_favorites
        expect(status).to eq(200)
      end

      context 'with valid parameters' do
        it 'should create Favorite record' do
          expect { xhr_post_favorites }.to change {
            Favorite.find_by(user: user, message: message)
          }.from(nil)
        end

        describe 'json response' do
          before { xhr_post_favorites }

          it "should include status 'success'" do
            expect(json_response['response']['status']).to eq('success')
          end

          it 'should include id of favorite has created' do
            n = json_response['results']['favorite']['id']
            expect(Favorite.find_by(id: n)).not_to be_nil
          end

          it 'should include favorites count of user' do
            expect(json_response['results']['favorite']['user']['favorites_count']).to eq(user.favorites.count)
          end
        end
      end

      context 'with invalid info' do
        before { message.id = nil }

        it 'should not create Favorite record' do
          expect { xhr_post_favorites }.not_to change {
            Favorite.find_by(user: user, message: message)
          }
        end

        describe 'json response' do
          before { xhr_post_favorites }

          it "should include status 'error'" do
            expect(json_response['response']['status']).to eq('error')
          end

          it 'should include error messages' do
            expect(json_response['response']['messages'].size).to be > 0
          end
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

      it 'should respond with 200' do
        xhr_delete_favorite(favorite)
        expect(status).to eq(200)
      end

      it 'should delete Favorite record' do
        expect { xhr_delete_favorite(favorite) }.to change {
          Favorite.exists?(favorite.id)
        }.from(true).to(false)
      end
    end
  end
end
