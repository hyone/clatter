require 'rails_helper'
include RequestHelpers


describe 'Posts page', type: :request do
  subject { page }
  let (:user) { FactoryGirl.create(:user) }

  describe 'POST /posts' do
    let (:new_post) { FactoryGirl.build(:post) }

    context 'as guest' do
      it 'should not create a post' do
        expect { post_post(new_post) }.not_to change(Post, :count)
      end

      it 'should redirect_to signin page' do
        post_post(new_post)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'as user' do
      before { signin user }

      it 'should create a post' do
        expect { post_post(new_post) }.to change(Post, :count).by(1)
      end

      it 'should redirect_to root_path' do
        post_post(new_post)
        expect(response).to redirect_to(root_path)
      end
    end
  end


  describe 'DELETE /posts' do
    let! (:a_post) { FactoryGirl.create(:post) }

    context 'as guest' do
      it 'should not delete a post' do
        expect { delete post_path(a_post) }.not_to change(Post, :count)
      end

      it 'should redirect_to signin page' do
        delete post_path(a_post)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'as user' do
      before { signin user }

      it 'should delete a post' do
        expect { delete post_path(a_post) }.to change(Post, :count).by(-1)
      end

      it 'should redirect_to root_path' do
        delete post_path(a_post)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
