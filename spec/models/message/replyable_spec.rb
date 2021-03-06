require 'rails_helper'

describe Message::Replyable, type: :model do
  let(:message) { FactoryGirl.create(:message) }
  subject { message }

  describe '#reply_relationships' do
    it { should respond_to(:reply_relationships) }
    it do
      should have_many(:reply_relationships)
        .class_name('Reply')
        .dependent(:destroy)
    end

    context 'when the message has replied 2 users' do
      let!(:reply1) { FactoryGirl.create(:reply, message: message) }
      let!(:reply2) { FactoryGirl.create(:reply, message: message) }

      it 'should have 2 reply_relationships' do
        expect(message.reply_relationships.count).to eq(2)
      end
    end
  end

  describe '#users_replied_to' do
    it { should respond_to(:users_replied_to) }
    it do
      should have_many(:users_replied_to)
        .through(:reply_relationships)
        .source(:to_user)
    end
  end

  describe '#parents' do
    it { should respond_to(:parents) }
    it do
      should have_many(:parents)
        .through(:reply_relationships)
        .source(:to_message)
    end
  end

  describe '#reverse_reply_relationships' do
    it { should respond_to(:reverse_reply_relationships) }
    it do
      should have_many(:reverse_reply_relationships)
        .with_foreign_key('to_message_id')
        .class_name('Reply')
    end

    context 'when the message has received 2 replies' do
      let!(:reply1) { FactoryGirl.create(:reply, to_message: message) }
      let!(:reply2) { FactoryGirl.create(:reply, to_message: message) }

      it 'should have 2 reverse_reply_relationships' do
        expect(message.reverse_reply_relationships.count).to eq(2)
      end
    end
  end

  describe '#replies' do
    it { should respond_to(:replies) }
    it do
      should have_many(:replies)
        .through(:reverse_reply_relationships)
        .source(:message)
    end
  end

  describe '#message_id_replied_to' do
    it { should respond_to(:message_id_replied_to) }
  end

  describe '#parent' do
    context 'when the message reply to the another message' do
      let!(:parent) { FactoryGirl.create(:message) }
      let!(:reply1) { FactoryGirl.create(:reply, message: message, to_message: parent) }

      it 'should return the another message' do
        expect(message.parent).to eq(parent)
      end
    end
  end

  describe '#reply?' do
    subject { message.reply? }

    context 'when message is reply' do
      let!(:message) { FactoryGirl.create(:message_with_reply) }
      it { should be_truthy }
    end

    context 'when message is not reply' do
      let!(:message) { FactoryGirl.create(:message) }
      it { should be_falsy }
    end
  end

  describe '::mentions_of' do
    include_context 'messages of followed users'

    let!(:reply_followed1) do
      FactoryGirl.create(
        :message_with_reply,
        user: followed1,
        users_replied_to: [user]
      )
    end
    let!(:reply_followed2) do
      FactoryGirl.create(
        :message_with_reply,
        user: followed2,
        users_replied_to: [user]
      )
    end
    let!(:reply_other) do
      FactoryGirl.create(
        :message_with_reply,
        user: other,
        users_replied_to: [user]
      )
    end

    it { expect(Message).to respond_to(:mentions_of) }

    context 'without filter' do
      subject { Message.mentions_of(user) }

      it 'should have all messages mentioned from anyone' do
        should contain_exactly(reply_followed1, reply_followed2, reply_other)
      end

      it 'should not have messages other than mentioned one' do
        should_not include(message_followed1, message_followed2, message_other)
      end
    end

    context 'with filter = :following' do
      subject { Message.mentions_of(user, filter: :following) }

      it 'should have only messages mentioned from followed users' do
        should contain_exactly(reply_followed1, reply_followed2)
      end

      it 'should not have messages other than one mentioned from followed users' do
        should_not include(
          message_followed1, message_followed2, message_other,
          reply_other
        )
      end
    end
  end

  describe '::descendants_of' do
    subject { Message.descendants_of(message) }

    include_context 'a conversation'

    it { expect(Message).to respond_to(:descendants_of) }

    context 'with root of conversation' do
      let(:message) { conversation00 }
      it 'should have all descendants messages' do
        should contain_exactly(
          conversation10, conversation20, conversation30, conversation40, conversation50,
          conversation41, conversation51
        )
      end
    end

    context 'with node of conversation' do
      let(:message) { conversation30 }
      it 'should have all descendants messages' do
        should contain_exactly(
          conversation40, conversation50, conversation41, conversation51
        )
      end
    end

    context 'with branch node of conversation' do
      let(:message) { conversation41 }
      it 'should have all descendants messages' do
        should contain_exactly(conversation51)
      end
    end

    context 'with leaf of conversation' do
      let(:message) { conversation50 }
      it { should be_empty }
    end
  end

  describe '::ancestors_of' do
    subject { Message.ancestors_of(message) }

    include_context 'a conversation'

    it { expect(Message).to respond_to(:ancestors_of) }

    context 'with root of conversation' do
      let(:message) { conversation00 }
      it { should be_empty }
    end

    context 'with node of conversation' do
      let(:message) { conversation30 }
      it 'should have all its ancestors messages' do
        should contain_exactly(conversation00, conversation10, conversation20)
      end
    end

    context 'with branch node of conversation' do
      let(:message) { conversation41 }
      it 'should have all its ancestors messages' do
        should contain_exactly(
          conversation00, conversation10, conversation20, conversation30
        )
      end
    end

    context 'with leaf of conversation' do
      let(:message) { conversation50 }
      it 'should have all its ancestors messages' do
        should contain_exactly(
          conversation00, conversation10, conversation20,
          conversation30, conversation40
        )
      end
    end
  end

  context 'after saved' do
    context 'when text includes @screen_name' do
      let(:user1) { FactoryGirl.create(:user) }
      let(:user2) { FactoryGirl.create(:user) }
      let(:text)  { "@#{user1.screen_name} @#{user2.screen_name} hello world" }
      let(:message) { FactoryGirl.build(:message, text: text) }

      it 'reply relationships should be created' do
        message.save
        expect(message.reply_relationships.count).to eq(2)
      end

      context 'when message_id_replied_to is set'  do
        let(:parent) { FactoryGirl.create(:message) }
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
