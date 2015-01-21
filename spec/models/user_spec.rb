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
    it { should ensure_length_of(:screen_name).is_at_most(15) }

    context 'when given proper screen_name' do
      let (:screen_names) { %w{
        a
        a19
        _hoge
        fuga_hoge
        fuga_hoge_hello
      } }
      it 'should be valid' do
        screen_names.each do |screen_name|
          expect(subject).to allow_value(screen_name).for(:screen_name)
        end
      end
    end

    context 'when given wrong format screen_name' do
      let (:screen_names) { %w{
        1abc
        _234
        hoge.fuga
        hoge-fuga
        long_long_long_name
      } }
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

  describe '#login' do
    it { should respond_to(:login) }
  end

  describe '#profile_image' do
    it { should respond_to(:profile_image) }
  end


  describe '#relationships' do
    it { should respond_to(:relationships) }
    it { should have_many(:relationships) }

    context 'with 2 followed_users' do
      before { FactoryGirl.create_list(:relationship, 2, follower: user) }

      it 'should have 2 relationships' do
        expect(user.relationships.count).to eq(2)
      end

      # test for dependent: destroy
      context 'when the user is destroyed' do
        before { user.destroy }
        its(:relationships) { should be_empty }
      end
    end
  end

  describe '#reverse_relationships' do
    it { should respond_to(:reverse_relationships) }
    it { should have_many(:reverse_relationships) }

    context 'with 2 followers' do
      before { FactoryGirl.create_list(:relationship, 2, followed: user) }

      it 'should have 2 reverse_relationships' do
        expect(user.reverse_relationships.count).to eq(2)
      end

      # test for dependent: destroy
      context 'when the user is destroyed' do
        before { user.destroy }
        its(:reverse_relationships) { should be_empty }
      end
    end
  end


  describe 'about reply' do
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


  describe '#followed_users' do
    it { should respond_to(:followed_users) }
    it { should have_many(:followed_users).through(:relationships) }
  end

  describe '#followers' do
    it { should respond_to(:followers) }
    it { should have_many(:followers).through(:reverse_relationships) }
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

  # reply

  describe '#reverse_reply_relationships' do
    it { should respond_to(:reverse_reply_relationships) }
    it { should have_many(:reverse_reply_relationships) }
  end

  describe '#replies_received' do
    it { should respond_to(:replies_received) }
    it { should have_many(:replies_received).through(:reverse_reply_relationships) }
  end
end
