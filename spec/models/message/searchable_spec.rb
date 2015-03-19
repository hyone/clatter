require 'rails_helper'


describe Message::Searchable, type: :model do
  describe '::from_self_and_followed_users' do
    include_examples 'setup followed users messages'

    subject { Message.from_self_and_followed_users(user) }

    it "should include user's messages" do
      should include(message_user)
    end

    it "should include followed user's messages" do
      should include(message_followed1, message_followed2)
    end

    it "should not include other user's messages" do
      should_not include(message_other)
    end
  end
end
