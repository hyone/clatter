# == Schema Information
#
# Table name: replies
#
#  id            :integer          not null, primary key
#  message_id    :integer          not null
#  to_user_id    :integer          not null
#  to_message_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_replies_on_message_id     (message_id)
#  index_replies_on_to_message_id  (to_message_id)
#  index_replies_on_to_user_id     (to_user_id)
#

require 'rails_helper'

describe Reply, type: :model do
  let(:user) { FactoryGirl.create(:user) }
  let(:message) { FactoryGirl.create(:message, user: user) }
  let(:user_replied_to) { FactoryGirl.create(:user) }
  let(:message_replied_to) { FactoryGirl.create(:message, user: user_replied_to) }
  let(:reply) do
    FactoryGirl.create(
      :reply,
      message: message,
      to_user: user_replied_to,
      to_message: message_replied_to
    )
  end

  subject { reply }

  it { should be_valid }

  describe '#message' do
    it { should respond_to(:message) }

    it { should validate_presence_of(:message) }
    it { should belong_to(:message) }

    it 'should return the message' do
      expect(reply.message).to eq(message)
    end

    context 'when the message is destroyed' do
      before do
        # XXX: must be initialize 'reply' here
        reply
        message.destroy
      end

      it 'should be deleted together' do
        expect(Reply.exists?(reply.id)).to be_falsey
      end
    end
  end

  describe '#to_message' do
    it { should respond_to(:to_message) }

    it { should belong_to(:to_message).class_name(:Message) }

    it 'should return the message is replied to' do
      expect(reply.to_message).to eq(message_replied_to)
    end
  end

  describe '#to_user' do
    it { should respond_to(:to_user) }

    it { should belong_to(:to_user).class_name(:User) }
    it { should validate_presence_of(:to_user) }

    it 'should return the user is replied to' do
      expect(reply.to_user).to eq(user_replied_to)
    end
  end
end
