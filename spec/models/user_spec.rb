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
    it { should validate_length_of(:screen_name).is_at_most(15) }

    context 'when given proper screen_name' do
      let (:screen_names) { %w[
        a
        a19
        _hoge
        fuga_hoge
        fuga_hoge_hello
      ] }
      it 'should be valid' do
        screen_names.each do |screen_name|
          expect(subject).to allow_value(screen_name).for(:screen_name)
        end
      end
    end

    context 'when given wrong format screen_name' do
      let (:screen_names) { %w[
        1abc
        _234
        hoge.fuga
        hoge-fuga
        long_long_long_name
      ] }
      it 'should not be valid' do
        screen_names.each do |screen_name|
          expect(subject).not_to allow_value(screen_name).for(:screen_name)
        end
      end
    end
  end

  describe '#name' do
    it { should respond_to(:name) }
    it { should validate_presence_of(:name) }
  end

  describe '#description' do
    it { should respond_to(:description) }
    it { should validate_length_of(:description).is_at_most(160) }
  end

  describe '#url' do
    it { should respond_to(:url) }
  end

  describe '#email' do
    it { should respond_to(:email) }
  end

  describe '#profile_image' do
    it { should respond_to(:profile_image) }
  end


  describe 'Authenticatable' do
    describe '#login' do
      it { should respond_to(:login) }
    end
  end


  describe 'MessageOwnable' do
    describe '#messages' do
      it { should respond_to(:messages) }
    end

    describe '#reverse_reply_relationships' do
      it { should respond_to(:reverse_reply_relationships) }
      it { should have_many(:reverse_reply_relationships)
                    .class_name('Reply')
                    .with_foreign_key('to_user_id')
                    .dependent(:destroy) }
    end

    describe '#replies_received' do
      it { should respond_to(:replies_received) }
      it { should have_many(:replies_received)
                    .through(:reverse_reply_relationships)
                    .source(:message) }
    end

    context 'when the user have 2 replies' do
      let! (:message1) { FactoryGirl.create(:message, user: user) }
      let! (:message2) { FactoryGirl.create(:message, user: user) }
      let! (:reply1) { FactoryGirl.create(:reply, message: message1) }
      let! (:reply2) { FactoryGirl.create(:reply, message: message2) }

      describe '#replies' do
        it 'should return 2 messages' do
          expect(user.replies.count).to eq(2)
        end
      end

      describe '#messages_without_replies' do
        let! (:message3) { FactoryGirl.create(:message, user: user) }

        it 'should include message that is not a reply' do
          expect(user.messages_without_replies).to include(message3)
        end

        it 'should not include replies' do
          [message1, message2].each do |r|
            expect(user.messages_without_replies).not_to include(r)
          end
        end
      end
    end
  end 


  describe 'Followable' do
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


    shared_examples 'setup followed users' do
      let! (:followed1) { FactoryGirl.create(:follow, follower: user).followed }
      let! (:followed2) { FactoryGirl.create(:follow, follower: user).followed }
      let! (:other) { FactoryGirl.create(:user) }
    end

    describe '::self_and_followed_users_ids_of' do
      subject { User.self_and_followed_users_ids_of(user).pluck('id') }

      context 'with 2 followed_users' do
        include_examples 'setup followed users'

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
        include_examples 'setup followed users'

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


  describe 'Favoritable' do
    describe '#favorite_relationships' do
      it { should respond_to(:favorite_relationships) }
      it { should have_many(:favorite_relationships)
                    .class_name('Favorite')
                    .dependent(:destroy) }
    end

    describe '#favorites' do
      it { should respond_to(:favorites) }
      it { should have_many(:favorites)
                    .through(:favorite_relationships)
                    .source(:message) }
    end
  end


  describe 'Retweetable' do
    describe '#retweet_relationships' do
      it { should respond_to(:retweet_relationships) }
      it { should have_many(:retweet_relationships)
                    .class_name('Retweet')
                    .dependent(:destroy) }
    end

    describe '#retweets' do
      it { should respond_to(:retweets) }
      it { should have_many(:retweets)
                    .through(:retweet_relationships)
                    .source(:message) }
    end
  end
end
