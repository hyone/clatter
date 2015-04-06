require 'rails_helper'

describe 'User Profile Panel', type: :feature, js: true do
  let!(:user) { FactoryGirl.create(:user) }
  before { visit user_path(user) }

  subject { page }

  it { should have_selector('.user-profile-name', text: user.name) }
  it { should have_selector('.user-profile-screen-name', text: user.screen_name) }
end
