require 'rails_helper'


describe 'Navigation', type: :feature do
  let (:user) { FactoryGirl.create(:user) }
  subject { page }

  before {
    signin user
    visit root_path
  }

  describe 'Home' do
    it { should have_link(I18n.t('views.navigation.home'), root_path) }
  end

  describe 'Users' do
    it { should have_link(I18n.t('views.navigation.users'), users_path) }
  end

  describe 'Search' do
    it { should have_selector('input#navigation-search-input') }
    it { should have_selector('button#navigation-search-submit') }
  end

  describe 'New Message', js: true  do
    before { click_button 'navigation-new-message' }

    it 'should display modal window' do
      expect(page.find('#message-dialog')).to be_visible
    end

    include_examples 'a postable form' do
      let (:prefix) { 'modal' }
    end
  end
end
