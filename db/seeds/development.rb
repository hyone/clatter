MAIN_USER = FactoryGirl.create(
  :user,
  screen_name: 'sample',
  name: 'sample'
)


def gen_users
  FactoryGirl.create_list(:user, 99)
end

def gen_messages
  users = User.order(created_at: :desc).limit(5).push(MAIN_USER)
  users.each do |user|
    50.times { |n|
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
    }
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


gen_users
gen_messages
gen_follows
