require 'rails_helper'

describe User, :type => :model do
  let (:user) { FactoryGirl.create(:user) }
  subject { user }

  it 'original user should be valid' do
    should be_valid
  end

  describe '#screen_name' do
    it { should respond_to(:screen_name) }
    it { should validate_presence_of(:screen_name) }
    it { should ensure_length_of(:screen_name).is_at_most(32) }
  end

  describe '#name' do
    it { should respond_to(:name) }
    it { should validate_presence_of(:name) }
  end

  describe '#description' do
    it { should respond_to(:description) }
    it { should ensure_length_of(:description).is_at_most(160) }
  end

  describe '#url' do
    it { should respond_to(:url) }
  end

  describe '#email' do
    it { should respond_to(:email) }
  end
end
