require 'rails_helper'

describe 'Authentication pages', type: :feature do
  let(:user) { FactoryGirl.create(:user) }

  subject { page }

  describe '404 not found error' do
    before { visit '/no_such_path' }

    describe 'content' do
      it { should have_title(I18n.t('views.errors.not_found.title')) }
      it { should have_content(I18n.t('views.errors.not_found.message')) }
    end
  end

  describe '500 internet server error' do
    before do
      allow_any_instance_of(UsersController).to receive(:show).and_raise('some error')
      visit user_path(user)
    end

    describe 'content' do
      it { should have_title(I18n.t('views.errors.internet_server_error.title')) }
      it { should have_content(I18n.t('views.errors.internet_server_error.message')) }
    end
  end
end
