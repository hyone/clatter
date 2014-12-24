require 'rails_helper'


describe Post, :type => :model do
  let (:post) { FactoryGirl.create(:post) }
  subject { post }

  it 'original post should be valid' do
    should be_valid
  end

  describe '#text' do
    it { should respond_to(:text) }
    it { should validate_presence_of(:text) }
    it { should ensure_length_of(:text).is_at_most(140) }
  end

  describe '#user' do
    it { should respond_to(:user) }
    it { should validate_presence_of(:user) }
    it { should belong_to(:user) }
  end

  describe '#reply_to' do
    it { should respond_to(:reply_to) }
    it { should belong_to(:reply_to).class_name('Post') }
  end

  describe '#created_at' do
    it { should respond_to(:created_at) }
  end
end
