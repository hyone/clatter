require 'rails_helper'


describe Message::Timelinable, type: :model do
  describe '::timeline_of' do
    include_context 'messages of followed users'

    subject { Message.timeline_of(user) }

    context 'about messages' do
      let! (:message_user_reply_to_followed) {
        FactoryGirl.create(:message_with_reply, user: user, users_replied_to: [followed1])
      }
      let! (:message_user_reply_to_other) {
        FactoryGirl.create(:message_with_reply, user: user, users_replied_to: [other])
      }

      it "should include all the user's messages" do
        expect(subject).to include(
          message_user,
          message_user_reply_to_followed,
          message_user_reply_to_other
        )
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


