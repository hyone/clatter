# == Schema Information
#
# Table name: messages
#
#  id              :integer          not null, primary key
#  text            :string           not null
#  user_id         :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  favorited_count :integer          default(0), not null
#  retweeted_count :integer          default(0), not null
#
# Indexes
#
#  index_messages_on_user_id                 (user_id)
#  index_messages_on_user_id_and_created_at  (user_id,created_at)
#

require 'rails_helper'


describe Message, type: :model do
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
end
