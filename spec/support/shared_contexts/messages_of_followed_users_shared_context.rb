shared_context 'messages of followed users' do
  include_context 'followed users'
  let! (:message_user)      { FactoryGirl.create(:message, user: user) }
  let! (:message_followed1) { FactoryGirl.create(:message, user: followed1) }
  let! (:message_followed2) { FactoryGirl.create(:message, user: followed2) }
  let! (:message_other)     { FactoryGirl.create(:message, user: other) }
end
