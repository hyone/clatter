require 'rails_helper'

def click_new_message
  click_on I18n.t('views.navigation.new_message')
end


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
    before { click_new_message }

    it 'should display modal window' do
      expect(page.find('#modal-message-form')).to be_visible
    end

    context 'with empty text' do
      it 'should be disabled message button' do
        expect(page).to have_selector('#modal-message-form-submit:disabled')
      end
    end

    context 'with some text' do
      before { fill_in 'modal-message-form-text', with: 'Hello World' }

      it 'should be enabled message button' do
        expect(page).to have_selector('#modal-message-form-submit')
        expect(page).not_to have_selector('#modal-message-form-submit:disabled')
      end

      it 'should display textarea count in normal color' do
        expect(page).not_to have_selector('#modal-message-form .message-form .text-danger')
      end

      context 'after submit' do
        it 'should create a new message' do
          expect { click_button 'modal-message-form-submit' }.to change(Message, :count).by(1)
        end
      end
    end

    context "with text that's length is near limit" do
      before { fill_in 'modal-message-form-text', with: 'a' * 131 }

      it 'should display textarea count in danger color' do
        expect(page).to have_selector('#modal-message-form .message-form .text-danger')
      end
    end

    context 'with too long text' do
      before { fill_in 'modal-message-form-text', with: 'a' * 141 }
      it 'should be disabled message button' do
        expect(page).to have_selector('#modal-message-form-submit:disabled')
      end

      it 'should display textarea count in danger color' do
        expect(page).to have_selector('#modal-message-form .message-form .text-danger')
      end
    end
  end
end
