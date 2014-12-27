require 'rails_helper'

def click_new_post
  click_on I18n.t('views.navigation.new_post')
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

  describe 'New Post', js: true  do
    before { click_new_post }

    it 'should display modal window' do
      expect(page.find('#modal-post-form')).to be_visible
    end

    context 'with empty text' do
      it 'should be disabled post button' do
        expect(page).to have_selector('#modal-post-form-submit:disabled')
      end
    end

    context 'with some text' do
      before { fill_in 'modal-post-form-text', with: 'Hello World' }

      it 'should be enabled post button' do
        expect(page).to have_selector('#modal-post-form-submit')
        expect(page).not_to have_selector('#modal-post-form-submit:disabled')
      end

      it 'should display textarea count in normal color' do
        expect(page).not_to have_selector('#modal-post-form .post-form .text-danger')
      end

      context 'after submit' do
        it 'should create a new post' do
          expect { click_button 'modal-post-form-submit' }.to change(Post, :count).by(1)
        end
      end
    end

    context "with text that's length is near limit" do
      before { fill_in 'modal-post-form-text', with: 'a' * 131 }

      it 'should display textarea count in danger color' do
        expect(page).to have_selector('#modal-post-form .post-form .text-danger')
      end
    end

    context 'with too long text' do
      before { fill_in 'modal-post-form-text', with: 'a' * 141 }
      it 'should be disabled post button' do
        expect(page).to have_selector('#modal-post-form-submit:disabled')
      end

      it 'should display textarea count in danger color' do
        expect(page).to have_selector('#modal-post-form .post-form .text-danger')
      end
    end
  end
end
