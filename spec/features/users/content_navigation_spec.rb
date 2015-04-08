require 'rails_helper'

describe 'Content Navigation Panel', type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user) }

  before do
    FactoryGirl.create_list(:message, 10, user: user)
    FactoryGirl.create_list(:follow, 4, follower: user)
    FactoryGirl.create_list(:follow, 5, followed: user)
    visit user_path(user)
  end

  # messages
  it 'should have messages link with its count' do
    expect(page).to have_link(I18n.t('vue.content_navigation.messages'), href: user_path(user))
    expect(page).to have_selector('.content-navigation-messages', text: user.messages.count)
  end

  # following
  it 'should have following link with its count' do
    expect(page).to have_link(I18n.t('vue.content_navigation.following'), href: following_user_path(user))
    expect(page).to have_selector('.content-navigation-following', text: user.followed_users.count)
  end

  # followers
  it 'should have followers link with its count' do
    expect(page).to have_link(I18n.t('vue.content_navigation.followers'), href: followers_user_path(user))
    expect(page).to have_selector('.content-navigation-followers', text: user.followers.count)
  end

  def path(user)
    user_path(user)
  end

  describe 'user actions button' do
    include_examples 'a user actionable button'
  end

  describe 'follow button' do
    include_examples 'a followable button', content_navigation: true
  end
end
