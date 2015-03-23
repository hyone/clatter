require 'rails_helper'
include ApiHelpers


describe 'Follows page', type: :request do
  let (:follower) { FactoryGirl.create(:user) }
  let! (:followed_user) { FactoryGirl.create(:user) }

  shared_examples 'following/followers stats' do
    it "should include count of follower's following" do
      expect(
        json_response['results']['follow']['follower']['following_count']
      ).to eq(follower.followed_users.count)
    end
    it "should include count of follower's followers" do
      expect(
        json_response['results']['follow']['follower']['followers_count']
      ).to eq(follower.followers.count)
    end
    it "should include count of followed_user's following" do
      expect(
        json_response['results']['follow']['followed_user']['following_count']
      ).to eq(followed_user.followed_users.count)
    end
    it "should include count of followed_user's followers" do
      expect(
        json_response['results']['follow']['followed_user']['followers_count']
      ).to eq(followed_user.followers.count)
    end
  end


  describe 'POST /follows' do
    def xhr_post_follows
      xhr :post, follows_path(format: 'json'), follow: { followed_id: followed_user.id }
    end

    context 'as guest' do
      it 'should respond with 401' do
        xhr_post_follows
        expect(status).to eq(401)
      end

      it 'should not create Follow record' do
        expect { xhr_post_follows }.not_to change(Follow, :count)
      end
    end

    context 'as user' do
      before { signin follower }

      it 'should respond with 200' do
        xhr_post_follows
        expect(status).to eq(200)
      end

      context 'with valid parameters' do
        it 'should create Follow record' do
          expect { xhr_post_follows }.to change {
            Follow.find_by(follower: follower, followed: followed_user)
          }.from(nil).to(be_a Follow)
        end

        describe 'json response' do
          before { xhr_post_follows }
          include_examples 'json success responsable'

          it 'should include id of new follow record' do
            expect(json_response['results']['follow']['id']).not_to be_nil
          end

          include_examples 'following/followers stats'
        end
      end

      context 'with invalid parameters' do
        before { followed_user.id = nil }

        it 'should respond with 500' do
          xhr_post_follows
          expect(status).to eq(500)
        end

        it 'should not create Message record' do
          expect { xhr_post_follows }.not_to change {
            Follow.find_by(follower: follower, followed: followed_user)
          }.from(nil)
        end

        describe 'json response' do
          before { xhr_post_follows }
          include_examples 'json error responsable'
        end
      end
    end
  end


  describe 'DELETE /follows/:id' do
    let  (:other_user) { FactoryGirl.create(:user) }
    let! (:follow) { FactoryGirl.create(:follow, follower: follower, followed: followed_user) }

    def xhr_delete_follow(m)
      xhr :delete, follow_path(follow, format: 'json')
    end

    context 'as guest' do
      it 'should respond with 401' do
        xhr_delete_follow(follow)
        expect(status).to eq(401)
      end

      it 'should not delete Follow record' do
        expect { xhr_delete_follow(follow) }.not_to change {
          Follow.exists?(follow.id)
        }.from(true)
      end
    end

    context 'as non owner' do
      before { signin other_user }

      it 'should respond with 401' do
        xhr_delete_follow(follow)
        expect(status).to eq(401)
      end

      it 'should not delete Follow record' do
        expect { xhr_delete_follow(follow) }.not_to change {
          Follow.exists?(follow.id)
        }.from(true)
      end
    end

    context 'as owner' do
      before { signin follower }

      it 'should respond with 200' do
        xhr_delete_follow(follow)
        expect(status).to eq(200)
      end

      context 'with valid parameters' do
        it 'should delete Follow record' do
          expect { xhr_delete_follow(follow) }.to change {
            Follow.exists?(follow.id)
          }.from(true).to(false)
        end

        describe 'json response' do
          before { xhr_delete_follow(follow) }
          include_examples 'json success responsable'
          include_examples 'following/followers stats'
        end
      end

      context 'with non existential id' do
        before { follow.id = 0 }

        it 'should respond with 404' do
          xhr_delete_follow(follow)
          expect(status).to eq(404)
        end

        it 'should not delete Follow record' do
          expect { xhr_delete_follow(follow) }.not_to change(follower.follow_relationships, :count)
        end
      end
    end
  end
end
