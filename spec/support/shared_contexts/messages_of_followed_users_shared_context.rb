shared_context 'messages of followed users' do
  let! (:user)      { FactoryGirl.create(:user) }
  let! (:followed1) { FactoryGirl.create(:follow, follower: user).followed }
  let! (:followed2) { FactoryGirl.create(:follow, follower: user).followed }
  let! (:other)     { FactoryGirl.create(:user) }
  # messages
  let! (:message_user)      { FactoryGirl.create(:message, user: user) }
  let! (:message_followed1) { FactoryGirl.create(:message, user: followed1) }
  let! (:message_followed2) { FactoryGirl.create(:message, user: followed2) }
  let! (:message_other)     { FactoryGirl.create(:message, user: other) }
end
