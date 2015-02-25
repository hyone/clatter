require 'rails_helper'


describe Retweet, type: :model do
  let (:retweet) { FactoryGirl.create(:retweet) }

  subject { retweet }

  it { should be_valid }

  describe '#user' do
    it { should respond_to(:user) }
    it { should validate_presence_of(:user) }
    it { should belong_to(:user) }
  end

  describe '#message' do
    it { should respond_to(:message) }
    it { should validate_presence_of(:message) }
    it { should belong_to(:message) }
  end
end
