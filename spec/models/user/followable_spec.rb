require 'rails_helper'


describe User::Followable, type: :model do
  let (:user) { FactoryGirl.create(:user) }
  subject { user }

  describe '#follow_relationships' do
    it { should respond_to(:follow_relationships) }
    it { should have_many(:follow_relationships)
         .class_name('Follow')
         .with_foreign_key('follower_id')
         .dependent(:destroy) }

    context 'with 2 followed_users' do
      before { FactoryGirl.create_list(:follow, 2, follower: user) }

      it 'should have 2 relationships' do
        expect(user.follow_relationships.count).to eq(2)
      end

      # test for dependent: destroy
      context 'when the user is destroyed' do
        before { user.destroy }
        its(:follow_relationships) { should be_empty }
      end
    end
  end

  describe '#reverse_follow_relationships' do
    it { should respond_to(:reverse_follow_relationships) }
    it { should have_many(:reverse_follow_relationships)
         .class_name('Follow')
         .with_foreign_key('followed_id')
         .dependent(:destroy) }

    context 'with 2 followers' do
      before { FactoryGirl.create_list(:follow, 2, followed: user) }

      it 'should have 2 reverse_follow_relationships' do
        expect(user.reverse_follow_relationships.count).to eq(2)
      end

      # test for dependent: destroy
      context 'when the user is destroyed' do
        before { user.destroy }
        its(:reverse_follow_relationships) { should be_empty }
      end
    end
  end

  describe '#followed_users' do
    it { should respond_to(:followed_users) }
    it { should have_many(:followed_users)
         .through(:follow_relationships)
         .source(:followed) }
  end

  describe '#followers' do
    it { should respond_to(:followers) }
    it { should have_many(:followers)
         .through(:reverse_follow_relationships)
         .source(:follower) }
  end

  describe '#followed_users_newer' do
    it { should respond_to(:followed_users_newer) }

    context 'with 3 followed_users' do
      let! (:follow1) { FactoryGirl.create(:follow, follower: user, created_at: 5.hours.ago) }
      let! (:follow2) { FactoryGirl.create(:follow, follower: user, created_at: 8.hours.ago) }
      let! (:follow3) { FactoryGirl.create(:follow, follower: user, created_at: 3.hours.ago) }
      before { FactoryGirl.create(:follow) } # non-user follow

      it 'should have the same set as #followed_users' do
        expect(user.followed_users_newer.sort).to eq(user.followed_users.sort)
      end

      it "should order 'follows.created_at desc'" do
        expect(user.followed_users_newer).to eq([follow3, follow1, follow2].map(&:followed))
      end
    end
  end

  describe '#followers_newer' do
    it { should respond_to(:followers_newer) }

    context 'with 3 followers' do
      let! (:follow1) { FactoryGirl.create(:follow, followed: user, created_at: 5.hours.ago) }
      let! (:follow2) { FactoryGirl.create(:follow, followed: user, created_at: 8.hours.ago) }
      let! (:follow3) { FactoryGirl.create(:follow, followed: user, created_at: 3.hours.ago) }
      before { FactoryGirl.create(:follow) } # non-user follow

      it 'should have the same set as #followers' do
        expect(user.followers_newer.sort).to eq(user.followers.sort)
      end

      it "should order 'follows.created_at desc'" do
        expect(user.followers_newer).to eq([follow3, follow1, follow2].map(&:follower))
      end
    end
  end

  describe '#follow!' do
    it { should respond_to(:follow!) }
  end

  describe '#unfollow!' do
    it { should respond_to(:unfollow!) }
  end

  context 'when following' do
    let (:other_user) { FactoryGirl.create(:user) }
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


  describe '::self_and_followed_users_ids_of' do
    subject { User.self_and_followed_users_ids_of(user).pluck('id') }

    context 'with 2 followed_users' do
      include_context 'followed users'

      it 'should include followed user ids' do
        expect(subject).to include(followed1.id)
        expect(subject).to include(followed2.id)
      end

      it 'should include the user id' do
        should include(user.id)
      end

      it 'should not include the other user id' do
        should_not include(other.id)
      end
    end

    context 'with no followed users' do
      it 'should include only the user id' do
        should contain_exactly(user.id)
      end
    end
  end

  describe '::self_and_followed_users_of' do
    subject { User.self_and_followed_users_of(user) }

    context 'with 2 followed_users' do
      include_context 'followed users'

      it 'should include followed users' do
        expect(subject).to include(followed1)
        expect(subject).to include(followed2)
      end

      it 'should include the user' do
        should include(user)
      end

      it 'should not include other users' do
        should_not include(other)
      end
    end

    context 'with no followed users' do
      it 'should include only the user' do
        should contain_exactly(user)
      end
    end
  end
end
