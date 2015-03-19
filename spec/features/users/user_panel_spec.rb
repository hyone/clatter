require 'rails_helper'


describe 'User Panel', type: :feature, js: true do
  let (:user) { FactoryGirl.create(:user) }
  before { visit user_path(user) }

  def path(user)
    users_path
  end

  describe 'user actions button' do
    include_examples 'a user actionable button'
  end

  describe 'follow button' do
    include_examples 'a followable button'
  end
end
