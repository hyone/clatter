require 'rails_helper'


describe 'Message Actions', type: :feature, js: true do
  let (:user) { FactoryGirl.create(:user) }

  subject { page }

  describe 'actions button' do
    describe 'delete message menu' do
      let! (:message) { FactoryGirl.create(:message, user: user) }
      let (:other_user) { FactoryGirl.create(:user) }
      before {
        visit user_path(user)
      }

      context 'as guest' do
        it 'should not be included in the dropdown' do
          should_not have_selector("#delete-message-#{message.id}", visible: false)
          # expect(find("#delete-message-#{message.id}", visible: false)).not_to be_visible
        end
      end

      context 'as non owner' do
        before {
          signin other_user
          visit current_path
        }
        it 'should not be included in the dropdown' do
          should_not have_selector("#delete-message-#{message.id}", visible: false)
          # expect(find("#delete-message-#{message.id}", visible: false)).not_to be_visible
        end
      end

      context 'as owner' do
        before {
          signin user
          visit current_path
        }

        it 'should be included in the dropdown menu' do
          should have_selector("#delete-message-#{message.id}", visible: false)
        end

        context 'when click the message actions button' do
          before {
            click_on "message-actions-#{message.id}"
          }

          it 'should display' do
            should have_selector("#delete-message-#{message.id}")
          end

          context 'and then click the menu' do
            it 'should delete the message' do
              expect {
                click_link "delete-message-#{message.id}"
                wait_for_ajax
              }.to change(Message, :count).by(-1)
            end

            it {
              click_link "delete-message-#{message.id}"
              wait_for_ajax
              expect(page).to have_alert(:success, I18n.t('views.alert.success_delete_message'))
            }
          end
        end
      end
    end
  end
end
