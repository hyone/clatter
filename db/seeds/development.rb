MAIN_USER = FactoryGirl.create(
  :user,
  screen_name: 'sample',
  name: 'sample',
  password: 'password'
)

def random_user
  User.offset(rand(User.count)).first
end

def random_message
  Message.offset(rand(Message.count)).first
end

def gen_users
  FactoryGirl.create_list(:user, 99)
end

def gen_messages
  # main users messages
  users = User.order(created_at: :desc).limit(5).push(MAIN_USER)
  users.each do |user|
    50.times do |n|
      if n % 5 != 0
        FactoryGirl.create(:message, user: user)
      else
        to_user = n.even? ? MAIN_USER : User.offset(rand(User.count)).first
        FactoryGirl.create(
          :message_with_reply,
          user: user,
          users_replied_to: [to_user]
        )
      end
    end
  end

  # message including URLs
  10.times do
    FactoryGirl.create(
      :message,
      user: MAIN_USER,
      text: "Hello, #{ rand(1..3).times.map { Faker::Internet.url }.join(' and ') }"
    )
  end

  # other users messages
  User.all.each do |user|
    FactoryGirl.create_list(:message, 10, user: user)
  end
end

def gen_follows
  users = User.all

  users[2..50].each do |followed_user|
    FactoryGirl.create(:follow, follower: MAIN_USER, followed: followed_user)
  end

  users[3..40].each do |follower|
    FactoryGirl.create(:follow, follower: follower, followed: MAIN_USER)
  end
end

def gen_favorites
  30.times  { FactoryGirl.create(:favorite, user: MAIN_USER, message: random_message) }
  200.times { FactoryGirl.create(:favorite, user: random_user, message: random_message) }
end

def gen_retweets
  30.times do
    m = random_message
    FactoryGirl.create(
      :retweet,
      user: MAIN_USER,
      message: m,
      created_at: m.created_at + rand(Time.now - m.created_at)
    )
  end
  200.times do
    m = random_message
    FactoryGirl.create(
      :retweet,
      user: random_user,
      message: m,
      created_at: m.created_at + rand(Time.now - m.created_at)
    )
  end
end

def gen_conversations
  companion = random_user
  message   = FactoryGirl.create(
    :message,
    user: MAIN_USER,
    text: 'CONVERSATION EXAMPLE',
    created_at: 1.hours.ago
  )
  user      = random_user
  companion = MAIN_USER

  10.times do |i|
    message = FactoryGirl.create(
      :message_with_reply,
      user: user,
      created_at: message.created_at + 5.minutes,
      users_replied_to: [companion],
      message_id_replied_to: message.id
    )

    # create a branch
    if i == 5
      m = message
      people = [random_user, user, companion]

      4.times do
        user_br, *companions_br = people

        m = FactoryGirl.create(
          :message_with_reply,
          user: user_br,
          created_at: m.created_at + 1.minute,
          users_replied_to: companions_br,
          message_id_replied_to: m.id
        )

        people.rotate!
      end
    end

    user, companion = companion, user
  end
end

gen_users
gen_messages
gen_follows
gen_favorites
gen_retweets
gen_conversations
