require 'rails_helper'


describe 'Navigation', type: :feature, js: true do
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
    it { should have_selector('#navigation-search-input') }
    it { should have_selector('#navigation-search-submit') }

    context 'with no input' do
      it 'search button should be disabled' do
        expect(page).to have_selector('#navigation-search-submit.disabled')
      end
    end

    context 'with some input' do
      before { fill_in 'navigation-search-input', with: 'keyword' }

      it 'search button should be enabled' do
        expect(page).to have_selector('#navigation-search-submit')
        expect(page).not_to have_selector('#navigation-search-submit.disabled')
      end

      context 'when submit' do
        before { click_on 'navigation-search-submit' }

        it 'should move to search page' do
          expect(current_path).to eq(search_path)
        end
      end
    end
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
