require 'rails_helper'


describe Message, :type => :model do
  let (:message) { FactoryGirl.create(:message) }
  subject { message }

  it 'original message should be valid' do
    should be_valid
  end

  describe '#text' do
    it { should respond_to(:text) }
    it { should validate_presence_of(:text) }
    it { should validate_length_of(:text).is_at_most(140) }
  end

  describe '#user' do
    it { should respond_to(:user) }
    it { should validate_presence_of(:user) }
    it { should belong_to(:user) }
  end

  describe '#created_at' do
    it { should respond_to(:created_at) }
  end


  describe 'Repliable' do
    describe '#reply_relationships' do
      it { should respond_to(:reply_relationships) }

      context 'when the message has replied 2 users' do
        let! (:reply1) { FactoryGirl.create(:reply, message: message) } 
        let! (:reply2) { FactoryGirl.create(:reply, message: message) }

        it 'should have 2 reply_relationships' do
          expect(message.reply_relationships.count).to eq(2)
        end
      end 
    end

    describe '#users_replied_to' do
      it { should respond_to(:users_replied_to) }

      context 'when the message has replied to 2 users' do
        let! (:reply1) { FactoryGirl.create(:reply, message: message) } 
        let! (:reply2) { FactoryGirl.create(:reply, message: message) }

        it 'should have 2 users_replied_to' do
          expect(message.users_replied_to.count).to eq(2)
        end
      end 
    end

    describe '#reverse_reply_relationships' do
      it { should respond_to(:reverse_reply_relationships) }

      context 'when the message has received 2 replies' do
        let! (:reply1) { FactoryGirl.create(:reply, to_message: message) }
        let! (:reply2) { FactoryGirl.create(:reply, to_message: message) }

        it 'should have 2 reverse_reply_relationships' do
          expect(message.reverse_reply_relationships.count).to eq(2)
        end
      end
    end

    describe '#message_id_replied_to' do
      it { should respond_to(:message_id_replied_to) }
    end


    describe '#parent' do
      context 'when the message reply to the another message' do
        let! (:parent) { FactoryGirl.create(:message) }
        let! (:reply1) { FactoryGirl.create(:reply, message: message, to_message: parent) }

        it 'should return the another message' do
          expect(message.parent).to eq(parent)
        end
      end
    end

    describe '#reply?' do
      subject { message.reply? }

      context 'when message is reply' do
        let! (:message) { FactoryGirl.create(:message_with_reply) }
        it { should be_truthy }
      end

      context 'when message is not reply' do
        let! (:message) { FactoryGirl.create(:message) }
        it { should be_falsy }
      end
    end

    describe '::mentions_of' do
      it { expect(Message).to respond_to(:mentions_of) }
    end


    context 'after saved' do
      context 'when text includes @screen_name' do
        let (:user1) { FactoryGirl.create(:user) }
        let (:user2) { FactoryGirl.create(:user) }
        let (:text)  { "@#{user1.screen_name} @#{user2.screen_name} hello world" }
        let (:message) { FactoryGirl.build(:message, text: text) }

        it 'reply relationships should be created' do
          message.save
          expect(message.reply_relationships.count).to eq(2)
        end

        context 'when message_id_replied_to is set'  do
          let (:parent) { FactoryGirl.create(:message) }
          before { message.message_id_replied_to = parent.id }

          it 'reply relationships created should have to_message_id' do
            message.save
            message.reply_relationships.each do |r|
              expect(r.to_message).not_to be_nil
            end
          end
        end
      end
    end
  end


  describe 'Favoritedable' do
    describe '#favorite_relationships' do
      it { should respond_to(:favorite_relationships) }
      it { should have_many(:favorite_relationships)
                    .class_name('Favorite')
                    .dependent(:destroy) }
    end

    describe '#favorited_users' do
      it { should respond_to(:favorited_users) }
      it { should have_many(:favorited_users)
                    .through(:favorite_relationships)
                    .source(:user) }
    end

    describe '#favorited_by' do
      subject { message.favorited_by(user) }

      let (:message) { FactoryGirl.create(:message) }
      let (:user)    { FactoryGirl.create(:user) }

      context 'when favorited by the user' do
        let! (:favorite) { FactoryGirl.create(:favorite, user: user, message: message) }
        it 'should return the favorite object' do
          should eq(favorite)
        end
      end

      context 'when not favorited by the user' do
        let! (:favorite) { FactoryGirl.create(:favorite, message: message) }
        it { should be_nil }
      end
    end
  end


  describe 'Retweetedable' do
    describe '#retweet_relationships' do
      it { should respond_to(:retweet_relationships) }
      it { should have_many(:retweet_relationships)
                    .class_name('Retweet')
                    .dependent(:destroy) }
    end

    describe '#retweeted_users' do
      it { should respond_to(:retweeted_users) }
      it { should have_many(:retweeted_users)
                    .through(:retweet_relationships)
                    .source(:user) }
    end
  end


  describe 'Timelinable' do
    describe '::timeline_of' do
      subject { Message.timeline_of(user) }

      let! (:user) { FactoryGirl.create(:user) }
      let! (:followed) { FactoryGirl.create(:follow, follower: user).followed }
      let! (:other) { FactoryGirl.create(:user) }

      let! (:message_user) { FactoryGirl.create(:message, user: user) }
      let! (:message_followed) { FactoryGirl.create(:message, user: followed) }
      let! (:message_other) { FactoryGirl.create(:message, user: other) }
      let! (:message_user_reply_to_followed) {
        FactoryGirl.create(:message_with_reply, user: user, users_replied_to: [followed])
      }
      let! (:message_user_reply_to_other) {
        FactoryGirl.create(:message_with_reply, user: user, users_replied_to: [other])
      }
      let! (:message_followed_reply_to_user) {
        FactoryGirl.create(:message_with_reply, user: followed, users_replied_to: [user])
      }
      let! (:message_followed_reply_to_other) {
        FactoryGirl.create(:message_with_reply, user: followed, users_replied_to: [other])
      }
      let! (:message_other_reply_to_user) {
        FactoryGirl.create(:message_with_reply, user: other, users_replied_to: [user])
      }

      it "should include all the user's message" do
        [
          message_user,
          message_user_reply_to_followed,
          message_user_reply_to_other
        ].each do |m|
          expect(subject).to include(m)
        end
      end

      it "should include followed user's non-reply message" do
        should include(message_followed)
      end

      it "should include followed user's reply to the user" do
        should include(message_followed_reply_to_user)
      end

      it "should not include non followed user's reply to the user" do
        should_not include(message_other_reply_to_user)
      end

      it "should not include any reply to other than the user" do
        should_not include(message_followed_reply_to_other)
      end
    end
  end
end
