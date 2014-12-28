require 'rails_helper'


describe 'Post Form', type: :feature, js: true do
  subject { page }

  context 'as user' do
    let (:user) { FactoryGirl.create(:user) }
    before {
      signin user
      visit root_path
    }

    it { should have_selector('textarea#content-main-post-form-text') }

    it 'submit button should be initially hidden' do
      expect(page.find('#content-main-post-form-submit', visible: false)).not_to be_visible
    end

    context 'when focus on textarea' do
      before {
        page.find('#content-main-post-form-text').trigger('focus')
      }

      it 'submit button should be visible' do
        expect(page.find('#content-main-post-form-submit')).to be_visible
      end

      context 'with empty text' do
        it 'should be disabled post button' do
          expect(page).to have_selector('#content-main-post-form-submit:disabled')
        end

        context 'and then when blur the textarea' do
          before {
            page.find('#content-main-post-form-text').trigger('blur')
          }
          it 'submit button should be hidden' do
            expect(page.find('#content-main-post-form-submit', visible: false)).not_to be_visible
          end
        end
      end

      context 'with some text' do
        before { fill_in 'content-main-post-form-text', with: 'Hello World' }

        it 'should be enabled post button' do
          expect(page).to have_selector('#content-main-post-form-submit')
          expect(page).not_to have_selector('#content-main-post-form-submit:disabled')
        end

        it 'should display textarea count in normal color' do
          expect(page).not_to have_selector('.posts-head .post-form .text-danger')
        end

        context 'and then when blur the textarea' do
          before {
            page.find('#content-main-post-form-text').trigger('blur')
          }
          it 'submit button should be visible' do
            expect(page.find('#content-main-post-form-submit')).to be_visible
          end
        end

        context 'after submit' do
          it 'should create a new post' do
            expect { click_button 'content-main-post-form-submit' }.to change(Post, :count).by(1)
          end
        end
      end

      context "with text that's length is near limit" do
        before { fill_in 'content-main-post-form-text', with: 'a' * 131 }

        it 'should display textarea count in danger color' do
          expect(page).to have_selector('.posts-head .post-form .text-danger')
        end
      end

      context 'with too long text' do
        before { fill_in 'content-main-post-form-text', with: 'a' * 141 }
        it 'should be disabled post button' do
          expect(page).to have_selector('#content-main-post-form-submit:disabled')
        end

        it 'should display textarea count in danger color' do
          expect(page).to have_selector('.posts-head .post-form .text-danger')
        end
      end
    end

  end
end
