require 'rails_helper'


shared_examples 'setup followed users messages' do
  let! (:user)      { FactoryGirl.create(:user) }
  let! (:followed1) { FactoryGirl.create(:follow, follower: user).followed }
  let! (:followed2) { FactoryGirl.create(:follow, follower: user).followed }
  let! (:other)     { FactoryGirl.create(:user) }
  # messages
  let! (:message_user)      { FactoryGirl.create(:message, user: user) }
  let! (:message_followed1) { FactoryGirl.create(:message, user: followed1) }
  let! (:message_followed2) { FactoryGirl.create(:message, user: followed2) }
  let! (:message_other)     { FactoryGirl.create(:message, user: other) }
end


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
      it { should have_many(:reply_relationships)
                    .class_name('Reply')
                    .dependent(:destroy) }

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
      it { should have_many(:users_replied_to)
                    .through(:reply_relationships)
                    .source(:to_user) }
    end

    describe '#parents' do
      it { should respond_to(:parents) }
      it { should have_many(:parents)
                    .through(:reply_relationships)
                    .source(:to_message) }
    end

    describe '#reverse_reply_relationships' do
      it { should respond_to(:reverse_reply_relationships) }
      it { should have_many(:reverse_reply_relationships)
                    .with_foreign_key('to_message_id')
                    .class_name('Reply')
                    .dependent(:destroy) }

      context 'when the message has received 2 replies' do
        let! (:reply1) { FactoryGirl.create(:reply, to_message: message) }
        let! (:reply2) { FactoryGirl.create(:reply, to_message: message) }

        it 'should have 2 reverse_reply_relationships' do
          expect(message.reverse_reply_relationships.count).to eq(2)
        end
      end
    end

    describe '#replies' do
      it { should respond_to(:replies) }
      it { should have_many(:replies)
                    .through(:reverse_reply_relationships)
                    .source(:message) }
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

    describe '#favorite_users' do
      it { should respond_to(:favorite_users) }
      it { should have_many(:favorite_users)
                    .through(:favorite_relationships)
                    .source(:user) }
    end

    describe '#favorited_by' do
      subject { message.favorited_by(user) }

      let (:message) { FactoryGirl.create(:message) }
      let (:user)    { FactoryGirl.create(:user) }

      context 'when favorited by the user' do
        let! (:favorite) { FactoryGirl.create(:favorite, user: user, message: message) }
        it 'should return the Favorite id' do
          should eq(favorite.id)
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

    describe '#retweet_users' do
      it { should respond_to(:retweet_users) }
      it { should have_many(:retweet_users)
                    .through(:retweet_relationships)
                    .source(:user) }
    end

    describe 'retweeted?' do
      let! (:message) { FactoryGirl.create(:message) }
      subject { message.retweeted? }

      context 'when have retweeted' do
        let! (:retweet) { FactoryGirl.create(:retweet, message: message) }
        it { should be_truthy }
      end

      context 'when have not retweeted' do
        it { should be_falsy }
      end
    end

    describe '#retweeted_by' do
      subject { message.retweeted_by(user) }

      let (:message) { FactoryGirl.create(:message) }
      let (:user)    { FactoryGirl.create(:user) }

      context 'when retweeted by the user' do
        let! (:retweet) { FactoryGirl.create(:retweet, user: user, message: message) }
        it 'should return the Retweet id' do
          should eq(retweet.id)
        end
      end

      context 'when not retweeted by the user' do
        let! (:retweet) { FactoryGirl.create(:retweet, message: message) }
        it { should be_nil }
      end
    end


    shared_examples 'setup retweets' do
      let  (:user) { FactoryGirl.create(:user) }
      let! (:message) { FactoryGirl.create(:message, user: user) }
      let! (:reply) { FactoryGirl.create(:message_with_reply, user: user) }
      let! (:retweet1) { FactoryGirl.create(:retweet, user: user) }
      let! (:retweet2) { FactoryGirl.create(:retweet, user: user) }
    end

    describe '::with_retweets_of' do
      include_examples 'setup retweets'
      subject { Message.with_retweets_of(user) }

      it 'should include the user message' do
        expect(subject).to include(message)
      end

      it 'should not include the reply the user makes' do
        expect(subject).to include(reply)
      end

      it 'should include both retweets' do
        expect(subject).to include(retweet1.message)
        expect(subject).to include(retweet2.message)
      end
    end

    describe '::with_retweets_without_replies_of' do
      include_examples 'setup retweets'
      subject { Message.with_retweets_without_replies_of(user) }

      it 'should include the user message' do
        expect(subject).to include(message)
      end

      it 'should not include the reply the user makes' do
        expect(subject).not_to include(reply)
      end

      it 'should include both retweets' do
        expect(subject).to include(retweet1.message)
        expect(subject).to include(retweet2.message)
      end
    end
  end


  describe 'Timelinable' do
    describe '::timeline_of' do
      include_examples 'setup followed users messages'

      subject { Message.timeline_of(user) }

      context 'about messages' do
        let! (:message_user_reply_to_followed) {
          FactoryGirl.create(:message_with_reply, user: user, users_replied_to: [followed1])
        }
        let! (:message_user_reply_to_other) {
          FactoryGirl.create(:message_with_reply, user: user, users_replied_to: [other])
        }

        it "should include all the user's messages" do
          [
            message_user,
            message_user_reply_to_followed,
            message_user_reply_to_other
          ].each do |m|
            expect(subject).to include(m)
          end
        end

        it "should include followed user's message" do
          should include(message_followed1)
        end

        it "should not include other's message" do
          should_not include(message_other)
        end
      end

      context 'about replies' do
        let! (:message_followed_reply_to_user) {
          FactoryGirl.create(:message_with_reply, user: followed1, users_replied_to: [user])
        }
        let! (:message_followed_reply_to_other) {
          FactoryGirl.create(:message_with_reply, user: followed1, users_replied_to: [other])
        }
        let! (:message_other_reply_to_user) {
          FactoryGirl.create(:message_with_reply, user: other, users_replied_to: [user])
        }

        it "should include followed user's reply to the user" do
          should include(message_followed_reply_to_user)
        end

        it "should not include other's reply to the user" do
          should_not include(message_other_reply_to_user)
        end

        it "should not include any reply to other than the user" do
          should_not include(message_followed_reply_to_other)
        end
      end


      context 'about retweeted messages' do
        let! (:retweet_by_user) {
          FactoryGirl.create(:retweet, user: user)
        }
        let! (:retweet_by_followed) {
          FactoryGirl.create(:retweet, user: followed1)
        }
        let! (:retweet_by_other) {
          FactoryGirl.create(:retweet, user: other)
        }

        it "should include message the user retweet" do
          should include(retweet_by_user.message)
        end

        it "should include message followed users retweet" do
          should include(retweet_by_followed.message)
        end

        it 'should not include message others retweet' do
          should_not include(retweet_by_other.message)
        end

        context "when retweet followed user's message" do
          let! (:retweet) { FactoryGirl.create(
            :retweet, user: user, message: message_followed1
          ) }

          it "retweet_id of result record should be empty" do
            m = subject.find(retweet.message.id)
            expect(m.retweet_id).to be_nil
          end
        end

        context 'when the message is retweeted by multiple followed users (or the user)' do
          let! (:retweet) { FactoryGirl.create(
            :retweet, user: user , message: retweet_by_followed.message
          ) }

          it "the message do not include twice" do
            expect(subject.where(id: retweet.message.id).size).to eq(1)
          end

          it "retweet_id of result record should be the original retweeter id" do
            m = subject.find(retweet.message.id)
            expect(m.retweet_id).to eq(retweet_by_followed.id)
          end
        end
      end
    end
  end


  describe 'Searchable' do
    describe '::from_self_and_followed_users' do
      include_examples 'setup followed users messages'

      subject { Message.from_self_and_followed_users(user) }

      it "should include user's messages" do
        should include(message_user)
      end

      it "should include followed user's messages" do
        should include(message_followed1)
        should include(message_followed2)
      end

      it "should not include other user's messages" do
        should_not include(message_other)
      end
    end
  end
end
