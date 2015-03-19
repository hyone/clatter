require 'rails_helper'


describe Message::Retweetedable, type: :model do
  let (:message) { FactoryGirl.create(:message) }
  subject { message }

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
