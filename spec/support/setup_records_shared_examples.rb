
# require conditions below:
# - let(:user) { Factorygirl.create(:user) }
#
shared_examples 'setup conversations' do
    let! (:other1) { FactoryGirl.create(:user) }
    let! (:other2) { FactoryGirl.create(:user) }

  # create conversation
    let! (:conversation00) { FactoryGirl.create(:message, user: user) }
    5.times do |i|
      let! ("conversation#{i+1}0".to_sym) {
        parent = eval "conversation#{i}0"
        FactoryGirl.create(
          :message_with_reply,
          user: i.odd? ? user : other1,
          message_id_replied_to: parent.id
        )
      }
    end

    # create branch
    let! (:conversation41) {
      FactoryGirl.create(
        :message_with_reply,
        user: other2,
        users_replied_to: [user, other1],
        message_id_replied_to: conversation30.id
      )
    }
    let! (:conversation51) {
      FactoryGirl.create(
        :message_with_reply,
        user: user,
        users_replied_to: [other1, other2],
        message_id_replied_to: conversation41.id
      )
    }
end


shared_examples 'setup followed users messages' do
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
