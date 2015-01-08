MAIN_USER = FactoryGirl.create(
  :user,
  screen_name: 'hoshijiro_dev',
  name: 'hoshijiro (dev)'
)


def gen_users
  99.times { |n| FactoryGirl.create(:user) }
end

def gen_messages
  users = User.order(created_at: :desc).limit(5).push(MAIN_USER)
  # users = User.order(created_at: :desc).push(MAIN_USER)
  users.each do |user|
    50.times { FactoryGirl.create(:message, user: user) }
  end
end

def gen_relations
  users = User.all

  users[2..50].each do |followed_user|
    FactoryGirl.create(:relationship, follower: MAIN_USER, followed: followed_user)
  end

  users[3..40].each do |follower|
    FactoryGirl.create(:relationship, follower: follower, followed: MAIN_USER)
  end
end


gen_users
gen_messages
gen_relations
