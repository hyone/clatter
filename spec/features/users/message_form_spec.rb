require 'rails_helper'


describe 'Message Form', type: :feature, js: true do
  subject { page }

  context 'as user' do
    let (:user) { FactoryGirl.create(:user) }
    before {
      signin user
      visit root_path
    }

    it { should have_selector('textarea#content-main-message-form-text') }

    it 'submit button should be initially hidden' do
      expect(page.find('#content-main-message-form-submit', visible: false)).not_to be_visible
    end

    context 'when focus on textarea' do
      before {
        page.find('#content-main-message-form-text').trigger('focus')
      }

      it 'submit button should be visible' do
        expect(page.find('#content-main-message-form-submit')).to be_visible
      end

      include_examples 'a postable form', :foldable do
        let (:prefix) { 'content-main' }
      end
    end
  end
end
