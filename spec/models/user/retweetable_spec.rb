require 'rails_helper'


describe User::Followable, type: :model do
  let (:user) { FactoryGirl.create(:user) }
  subject { user }

  describe '#retweet_relationships' do
    it { should respond_to(:retweet_relationships) }
    it { should have_many(:retweet_relationships)
                  .class_name('Retweet')
                  .dependent(:destroy) }
  end

  describe '#retweets' do
    it { should respond_to(:retweets) }
    it { should have_many(:retweets)
                  .through(:retweet_relationships)
                  .source(:message) }
  end
end
