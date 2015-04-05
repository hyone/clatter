
shared_context 'a conversation' do
  let!(:user)   { FactoryGirl.create(:user) }
  let!(:other1) { FactoryGirl.create(:user) }
  let!(:other2) { FactoryGirl.create(:user) }

  # create conversation
  let!(:conversation00) { FactoryGirl.create(:message, user: user) }
  5.times do |i|
    let!(:"conversation#{i + 1}0") do
      parent = eval "conversation#{i}0"
      FactoryGirl.create(
        :message_with_reply,
        user: i.odd? ? user : other1,
        message_id_replied_to: parent.id
      )
    end
  end

  # create branch
  let!(:conversation41) do
    FactoryGirl.create(
      :message_with_reply,
      user: other2,
      users_replied_to: [user, other1],
      message_id_replied_to: conversation30.id
    )
  end
  let!(:conversation51) do
    FactoryGirl.create(
      :message_with_reply,
      user: user,
      users_replied_to: [other1, other2],
      message_id_replied_to: conversation41.id
    )
  end
end
