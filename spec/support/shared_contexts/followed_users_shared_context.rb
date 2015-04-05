shared_context 'followed users' do
  let!(:user)      { FactoryGirl.create(:user) }
  let!(:followed1) { FactoryGirl.create(:follow, follower: user).followed }
  let!(:followed2) { FactoryGirl.create(:follow, follower: user).followed }
  let!(:other)     { FactoryGirl.create(:user) }
end
