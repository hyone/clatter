require 'rails_helper'


describe User::MessageOwnable, type: :model do
  let (:user) { FactoryGirl.create(:user) }
  subject { user }

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



