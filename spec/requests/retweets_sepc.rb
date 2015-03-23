require 'rails_helper'
include ApiHelpers


describe 'Retweets pages' do
  let! (:user) { FactoryGirl.create(:user) }
  let! (:message) { FactoryGirl.create(:message) }

  describe 'POST /retweets' do
    def xhr_post_retweets
      xhr :post, retweets_path(format: 'json'), retweet: { message_id: message.id }
    end

    context 'as guest' do
      it 'should respond with 401' do
        xhr_post_retweets
        expect(status).to eq(401)
      end
    end

    context 'as user' do
      before { signin user }


      context 'with valid parameters' do
        it 'should respond with 200' do
          xhr_post_retweets
          expect(status).to eq(200)
        end

        it 'should create Retweet record' do
          expect { xhr_post_retweets }.to change {
            Retweet.find_by(user: user, message: message)
          }.from(nil).to(be_a Retweet)
        end

        describe 'json response' do
          before { xhr_post_retweets }

          include_examples 'json success responsable'

          it 'should include id of retweet has created' do
            n = json_response['results']['retweet']['id']
            expect(Retweet.find_by(id: n)).not_to be_nil
          end
        end
      end

      context 'with invalid parameters' do
        before { message.id = nil }

        it 'should respond with 500' do
          xhr_post_retweets
          expect(status).to eq(500)
        end

        it 'should not create Retweet record' do
          expect { xhr_post_retweets }.not_to change {
            Retweet.find_by(user: user, message: message)
          }.from(nil)
        end

        describe 'json response' do
          before { xhr_post_retweets }
          include_examples 'json error responsable'
        end
      end

      context "with user's own message" do
        let! (:message) { FactoryGirl.create(:message, user: user) }

        it 'should respond with 401' do
          xhr_post_retweets
          expect(status).to eq(401)
        end
      end
    end
  end


  describe 'DELETE /retweets/:id' do
    let! (:retweet) { FactoryGirl.create(:retweet, user: user, message: message) }

    def xhr_delete_retweet(m)
      xhr :delete, retweet_path(m, format: 'json')
    end

    context 'as guest' do
      it 'should response with 401' do
        xhr_delete_retweet(retweet)
        expect(status).to eq(401)
      end
    end

    context 'as non owner' do
      let (:other_user) { FactoryGirl.create(:user) }
      before { signin other_user }
      it 'should response with 401' do
        xhr_delete_retweet(retweet)
        expect(status).to eq(401)
      end
    end

    context 'as owner' do
      before { signin user }

      context 'with valid parameters' do
        it 'should respond with 200' do
          xhr_delete_retweet(retweet)
          expect(status).to eq(200)
        end

        it 'should delete Retweet record' do
          expect { xhr_delete_retweet(retweet) }.to change {
            Retweet.exists?(retweet.id)
          }.from(true).to(false)
        end

        describe 'json response' do
          before { xhr_delete_retweet(retweet) }
          include_examples 'json success responsable'
        end
      end

      context 'with non existential id' do
        before { retweet.id = 0 }

        it 'should respond with 404' do
          xhr_delete_retweet(retweet)
          expect(status).to eq(404)
        end

        it 'should not delete Retweet record' do
          expect { xhr_delete_retweet(retweet) }.not_to change(user.retweets, :count)
        end
      end
    end
  end
end

