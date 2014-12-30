require 'rails_helper'

describe User, :type => :model do
  let (:user) { FactoryGirl.create(:user) }
  subject { user }

  it 'original user should be valid' do
    should be_valid
  end

  describe '#screen_name' do
    it { should respond_to(:screen_name) }
    it { should validate_presence_of(:screen_name) }
    it { should ensure_length_of(:screen_name).is_at_most(32) }
  end

  describe '#name' do
    it { should respond_to(:name) }
    it { should validate_presence_of(:name) }
  end

  describe '#description' do
    it { should respond_to(:description) }
    it { should ensure_length_of(:description).is_at_most(160) }
  end

  describe '#url' do
    it { should respond_to(:url) }
  end

  describe '#email' do
    it { should respond_to(:email) }
  end

  describe '#messages' do
    it { should respond_to(:messages) }
  end


  describe '#relationships' do
    let! (:relationship) { FactoryGirl.create(:relationship, follower: user) }

    it { should respond_to(:relationships) }

    it 'should have 1 relationship' do
      expect(user.relationships.count).to eq(1)
    end

    # test for dependent: destroy
    context 'when the user is destroyed' do
      before { user.destroy }
      its(:relationships) { should be_empty }
    end
  end

  describe '#reverse_relationships' do
    let! (:reverse_relationships) { FactoryGirl.create(:relationship, followed: user) }

    it { should respond_to(:reverse_relationships) }

    it 'should have 1 reverse_relationship' do
      expect(user.reverse_relationships.count).to eq(1)
    end

    # test for dependent: destroy
    context 'when the user is destroyed' do
      before { user.destroy }
      its(:reverse_relationships) { should be_empty }
    end
  end

  describe '#followed_users' do
    it { should respond_to(:followed_users) }
  end

  describe '#followers' do
    it { should respond_to(:followers) }
  end

  describe '#follow!' do
    it { should respond_to(:follow!) }
  end

  describe '#unfollow!' do
    it { should respond_to(:unfollow!) }
  end


  describe 'about follow' do
    let (:other_user) { FactoryGirl.create(:user) }

    context 'when following' do
      before {
        user.follow!(other_user)
      }

      it 'should be following other_user' do
        expect(user).to be_following(other_user)
      end

      it 'followed_users should include other_user' do
        expect(user.followed_users).to include(other_user)
      end

      context 'and then unfollowing' do
        before { user.unfollow!(other_user) }

        it 'should not be following other_user' do
          expect(user).not_to be_following(other_user)
        end

        it 'followed_users should not include other_user' do
          expect(user.followed_users).not_to include(other_user)
        end
      end

      context 'from followed_user' do
        it 'other_user.followers should include user' do
          expect(other_user.followers).to include(user)
        end
      end
    end


  end
end
