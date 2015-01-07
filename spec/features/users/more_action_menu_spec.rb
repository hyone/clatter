require 'rails_helper'


describe 'More Actions Menu', type: :feature, js: true do
  subject { page }

  shared_examples 'more actions menu' do
    context 'when open more actions menu' do
      before {
        # open 'more actions' menu
        click_button "#{target.screen_name}-actions-button"
      }

      context 'and then click "message to @screen_name" button' do
        before {
          # select menu
          click_link "reply-to-#{target.screen_name}"
        }

        it 'should display modal window' do
          expect(page.find('#message-dialog')).to be_visible
        end

        it "text should be set to '@screen_name'" do
          expect(find('#modal-message-form-text').value).to match /@#{target.screen_name}/
        end
      end
    end
  end


  context 'as user' do
    let (:user) { FactoryGirl.create(:user) }
    before { signin user }

    context 'in content navigation' do
      it_behaves_like 'more actions menu' do
        let (:target) { FactoryGirl.create(:user) }
        before { visit user_path(target) }  
      end
    end

    context 'in user panel' do
      it_behaves_like 'more actions menu' do
        let! (:target) { FactoryGirl.create(:user) }
        before { visit users_path }  
      end
    end
  end
end
